import 'package:bondgrid/constants/error_codes.dart';
import 'package:bondgrid/constants/error_message.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/models/cash_balance.dart';
import 'package:bondgrid/models/payment_method_list.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/repo/wallet_repo.dart';
import 'package:bondgrid/services/cache_data.dart';
import 'package:bondgrid/services/token_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WalletStateStatus {
  initial,
  loading,
  success,
  failure,
}

class WalletState extends Equatable {
  final WalletStateStatus status;
  final String errorMessage;

  const WalletState(
      {this.status = WalletStateStatus.initial, this.errorMessage = ""});

  @override
  List<Object?> get props => [status, errorMessage];
}

class DeletePaymentLoadingState extends WalletState {
  const DeletePaymentLoadingState() : super(status: WalletStateStatus.loading);

  @override
  List<Object?> get props => [status];
}

class PaymentMethodSuccessState extends WalletState {
  final PaymentMethodList paymentMethods;

  const PaymentMethodSuccessState({required this.paymentMethods})
      : super(status: WalletStateStatus.success);

  @override
  List<Object?> get props => [status, errorMessage, paymentMethods];
}

class DeletePaymentMethodSuccessState extends WalletState {
  const DeletePaymentMethodSuccessState()
      : super(status: WalletStateStatus.success);

  @override
  List<Object?> get props => [status];
}

class GetCashBalanceSuccessState extends WalletState {
  final CashBalance cashBalance;

  const GetCashBalanceSuccessState({required this.cashBalance})
      : super(status: WalletStateStatus.success);

  @override
  List<Object> get props => [cashBalance];
}

class LoadInitialDataLoadingState extends WalletState {
  const LoadInitialDataLoadingState()
      : super(status: WalletStateStatus.loading);
}

class LoadInitialDataSuccessState extends WalletState {
  final UserInfo userInfo;
  final CashBalance cashBalance;
  final PaymentMethodList paymentMethods;

  const LoadInitialDataSuccessState(
      {required this.userInfo,
      required this.cashBalance,
      required this.paymentMethods})
      : super(status: WalletStateStatus.success);

  @override
  List<Object> get props => [userInfo, cashBalance, paymentMethods];
}

class FailureState extends WalletState {
  const FailureState(String errorMessage)
      : super(status: WalletStateStatus.failure, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}

class WalletEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetPaymentMethodsEvent extends WalletEvent {
  GetPaymentMethodsEvent();
}

class DeletePaymentMethodEvent extends WalletEvent {
  final String paymentMethodId;

  DeletePaymentMethodEvent(this.paymentMethodId);
}

class GetCashBalanceEvent extends WalletEvent {
  GetCashBalanceEvent();
}

class LoadInitialDataEvent extends WalletEvent {
  final bool useCache;

  LoadInitialDataEvent({this.useCache = true});
}

extension on WalletBloc {
  void _handleError(dynamic error, Emitter<WalletState> emit) {
    if (error is ApiException) {
      switch (error.errorCode) {
        case ErrorCodes.ASSOCIATED_TRANSACTIONS_FOUND:
          emit(const FailureState(
              "Cannot delete payment method while there are pending transactions associated with it."));
          break;
        default:
          emit(FailureState(ErrorMessage.unexpectedErrorMessage));
          break;
      }
    } else {
      emit(FailureState(ErrorMessage.unexpectedErrorMessage));
    }
  }
}

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepo walletRepo;

  WalletBloc(this.walletRepo) : super(const WalletState()) {
    on<GetPaymentMethodsEvent>((event, emit) async {
      emit(const WalletState(status: WalletStateStatus.loading));
      try {
        PaymentMethodList response = await walletRepo.getPaymentMethods();
        emit(PaymentMethodSuccessState(paymentMethods: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<DeletePaymentMethodEvent>((event, emit) async {
      emit(const DeletePaymentLoadingState());
      try {
        await walletRepo.deletePaymentMethod(event.paymentMethodId);
        add(GetPaymentMethodsEvent());
        //emit(const DeletePaymentMethodSuccessState());
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetCashBalanceEvent>((event, emit) async {
      emit(const WalletState(status: WalletStateStatus.loading));
      try {
        CashBalance response = await walletRepo.getPortfolioValue();
        emit(GetCashBalanceSuccessState(cashBalance: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<LoadInitialDataEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = await TokenService.getJWTToken();

      // Try to load cached data
      if (currentUserId != null && event.useCache) {
        final cachedCashBalanceData =
            readCachedData(prefs, 'cachedCashBalance', currentUserId);
        final cachedPaymentListData =
            readCachedData(prefs, 'cachedPaymentList', currentUserId);
        final cachedUserInfoData =
            readCachedData(prefs, 'cachedUserInfo', currentUserId);

        // Deserialize data if available
        CashBalance? cachedCashBalance = cachedCashBalanceData != null
            ? CashBalance.fromJson(cachedCashBalanceData)
            : null;
        PaymentMethodList? cachedPaymentList = cachedPaymentListData != null
            ? PaymentMethodList.fromJson(cachedPaymentListData)
            : null;
        UserInfo? cachedUserInfo = cachedUserInfoData != null
            ? UserInfo.fromJson(cachedUserInfoData)
            : null;

        // If any cached data is missing or outdated, emit loading and fetch data
        if (cachedCashBalance == null ||
            cachedPaymentList == null ||
            cachedUserInfo == null) {
          emit(const LoadInitialDataLoadingState());
        } else {
          emit(LoadInitialDataSuccessState(
              userInfo: cachedUserInfo,
              paymentMethods: cachedPaymentList,
              cashBalance: cachedCashBalance));
        }
      } else {
        emit(const LoadInitialDataLoadingState());
      }

      try {
        // Fetch assets and cash balance concurrently
        final futureUserInfo = walletRepo.getUserInformation();
        final futurePaymentList = walletRepo.getPaymentMethods();
        final futureCashBalance = walletRepo.getPortfolioValue();

        final results = await Future.wait(
            [futureUserInfo, futurePaymentList, futureCashBalance]);

        UserInfo userInfo = results[0] as UserInfo;
        PaymentMethodList paymentMethodList = results[1] as PaymentMethodList;
        CashBalance cashBalance = results[2] as CashBalance;

        // Cache new data with timestamps
        if (currentUserId != null) {
          await cacheData(
              prefs, 'cachedUserInfo', userInfo.toJson(), currentUserId);
          await cacheData(prefs, 'cachedPaymentList',
              paymentMethodList.toJson(), currentUserId);
          await cacheData(
              prefs, 'cachedCashBalance', cashBalance.toJson(), currentUserId);
        }

        emit(LoadInitialDataSuccessState(
            userInfo: userInfo,
            paymentMethods: paymentMethodList,
            cashBalance: cashBalance));
      } catch (error) {
        _handleError(error, emit);
      }
    });
  }
}
