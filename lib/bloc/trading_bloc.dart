import 'package:bondgrid/constants/error_message.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/models/asset_list.dart';
import 'package:bondgrid/models/cash_balance.dart';
import 'package:bondgrid/models/payment_method_list.dart';
import 'package:bondgrid/models/purchase_response.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/repo/trading_repo.dart';
import 'package:bondgrid/services/cache_data.dart';
import 'package:bondgrid/services/token_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TradingStateStatus {
  initial,
  loading,
  success,
  failure,
}

class TradingState extends Equatable {
  final TradingStateStatus status;
  final String errorMessage;

  const TradingState(
      {this.status = TradingStateStatus.initial, this.errorMessage = ""});

  @override
  List<Object?> get props => [status, errorMessage];
}

class FailureState extends TradingState {
  const FailureState(String errorMessage)
      : super(status: TradingStateStatus.failure, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}

class GetAssetListSuccessState extends TradingState {
  final AssetList assetList;

  const GetAssetListSuccessState({required this.assetList})
      : super(status: TradingStateStatus.success);

  @override
  List<Object> get props => [assetList];
}

class GetBuyingPowerSuccessState extends TradingState {
  final CashBalance cashBalance;

  const GetBuyingPowerSuccessState({required this.cashBalance})
      : super(status: TradingStateStatus.success);

  @override
  List<Object> get props => [cashBalance];
}

class TradingPaymentMethodSuccessState extends TradingState {
  final PaymentMethodList paymentMethods;

  const TradingPaymentMethodSuccessState({required this.paymentMethods})
      : super(status: TradingStateStatus.success);

  @override
  List<Object?> get props => [status, errorMessage, paymentMethods];
}

class CreatePurchaseLoadingState extends TradingState {
  const CreatePurchaseLoadingState()
      : super(status: TradingStateStatus.loading);

  @override
  List<Object?> get props => [status];
}

class CreatePurchaseSuccessState extends TradingState {
  final PurchaseResponse purchaseResponse;

  const CreatePurchaseSuccessState({required this.purchaseResponse})
      : super(status: TradingStateStatus.success);

  @override
  List<Object?> get props => [status, purchaseResponse];
}

class LoadInitialDataLoadingState extends TradingState {
  const LoadInitialDataLoadingState()
      : super(status: TradingStateStatus.loading);

  @override
  List<Object> get props => [];
}

class LoadInitialDataSuccessState extends TradingState {
  final UserInfo userInfo;
  final AssetList assetList;

  const LoadInitialDataSuccessState(
      {required this.userInfo, required this.assetList})
      : super(status: TradingStateStatus.success);

  @override
  List<Object> get props => [userInfo, assetList];
}

class LoadInitialBuyDataLoadingState extends TradingState {
  const LoadInitialBuyDataLoadingState()
      : super(status: TradingStateStatus.loading);

  @override
  List<Object> get props => [];
}

class LoadInitialBuyDataSuccessState extends TradingState {
  final PaymentMethodList paymentMethods;
  final CashBalance cashBalance;

  const LoadInitialBuyDataSuccessState(
      {required this.paymentMethods, required this.cashBalance})
      : super(status: TradingStateStatus.success);

  @override
  List<Object?> get props =>
      [status, errorMessage, paymentMethods, cashBalance];
}

class TradingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetAssetListEvent extends TradingEvent {
  GetAssetListEvent();
}

class TradingGetPaymentMethodsEvent extends TradingEvent {
  TradingGetPaymentMethodsEvent();
}

class CreatePurchaseEvent extends TradingEvent {
  final String amount;
  final String cusip;
  final String fundSourceType;
  final String paymentMethodId;
  final String duration;
  final bool autoRoll;

  CreatePurchaseEvent(this.amount, this.cusip, this.fundSourceType,
      this.paymentMethodId, this.duration, this.autoRoll);
}

class GetBuyingPowerEvent extends TradingEvent {
  GetBuyingPowerEvent();
}

class LoadInitialDataEvent extends TradingEvent {
  final bool useCache;

  LoadInitialDataEvent({this.useCache = true});
}

class LoadInitialBuyDataEvent extends TradingEvent {
  LoadInitialBuyDataEvent();
}

extension on TradingBloc {
  void _handleError(dynamic error, Emitter<TradingState> emit) {
    if (error is ApiException) {
      switch (error.errorCode) {
        default:
          emit(FailureState(ErrorMessage.unexpectedErrorMessage));
          break;
      }
    } else {
      emit(FailureState(ErrorMessage.unexpectedErrorMessage));
    }
  }
}

class TradingBloc extends Bloc<TradingEvent, TradingState> {
  final TradingRepo tradingRepo;

  TradingBloc(this.tradingRepo) : super(const TradingState()) {
    on<GetAssetListEvent>((event, emit) async {
      emit(const TradingState(status: TradingStateStatus.loading));
      try {
        AssetList response = await tradingRepo.getAssetList();
        emit(GetAssetListSuccessState(assetList: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<TradingGetPaymentMethodsEvent>((event, emit) async {
      emit(const TradingState(status: TradingStateStatus.loading));
      try {
        PaymentMethodList response = await tradingRepo.getPaymentMethods();
        emit(TradingPaymentMethodSuccessState(paymentMethods: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<CreatePurchaseEvent>((event, emit) async {
      //emit(const TradingState(status: TradingStateStatus.loading));
      emit(const CreatePurchaseLoadingState());
      try {
        PurchaseResponse response = await tradingRepo.createPurchaseTrade(
            event.amount,
            event.cusip,
            event.fundSourceType,
            event.paymentMethodId,
            event.duration,
            event.autoRoll);
        final prefs = await SharedPreferences.getInstance();
        invalidateCache(prefs, 'cachedHoldingData_${response.holdingId}');
        emit(CreatePurchaseSuccessState(purchaseResponse: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetBuyingPowerEvent>((event, emit) async {
      emit(const TradingState(status: TradingStateStatus.loading));
      try {
        CashBalance response = await tradingRepo.getOnlyBuyingPower();
        emit(GetBuyingPowerSuccessState(cashBalance: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<LoadInitialDataEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = await TokenService.getJWTToken();

      // Try to load cached data
      if (currentUserId != null && event.useCache) {
        final cachedUserInfoData =
            readCachedData(prefs, 'cachedUserInfo', currentUserId);
        final cachedAssetListData =
            readCachedData(prefs, 'cachedAssetList', currentUserId);

        // Deserialize data if available
        UserInfo? userInfo = cachedUserInfoData != null
            ? UserInfo.fromJson(cachedUserInfoData)
            : null;
        AssetList? assetList = cachedAssetListData != null
            ? AssetList.fromJson(cachedAssetListData)
            : null;

        // If any cached data is missing or outdated, emit loading and fetch data
        if (userInfo == null || assetList == null) {
          emit(const LoadInitialDataLoadingState());
        } else {
          emit(LoadInitialDataSuccessState(
              userInfo: userInfo, assetList: assetList));
        }
      } else {
        emit(const LoadInitialDataLoadingState());
      }

      try {
        // Fetch assets and cash balance concurrently
        final futureUserInfo = tradingRepo.getUserInformation();
        final futureAssetList = tradingRepo.getAssetList();

        final results = await Future.wait([futureUserInfo, futureAssetList]);

        UserInfo userInfo = results[0] as UserInfo;
        AssetList assetList = results[1] as AssetList;

        // Cache new data with timestamps
        if (currentUserId != null) {
          await cacheData(
              prefs, 'cachedUserInfo', userInfo.toJson(), currentUserId);
          await cacheData(
              prefs, 'cachedAssetList', assetList.toJson(), currentUserId);
        }

        emit(LoadInitialDataSuccessState(
            userInfo: userInfo, assetList: assetList));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<LoadInitialBuyDataEvent>((event, emit) async {
      emit(const LoadInitialBuyDataLoadingState());
      try {
        final futurePaymentMethodList = tradingRepo.getPaymentMethods();
        final futureCashBalance = tradingRepo.getOnlyBuyingPower();

        final results =
            await Future.wait([futurePaymentMethodList, futureCashBalance]);

        PaymentMethodList paymentMethodsList = results[0] as PaymentMethodList;
        CashBalance cashBalance = results[1] as CashBalance;

        emit(LoadInitialBuyDataSuccessState(
            paymentMethods: paymentMethodsList, cashBalance: cashBalance));
      } catch (error) {
        _handleError(error, emit);
      }
    });
  }
}
