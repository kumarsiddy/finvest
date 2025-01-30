import 'package:bondgrid/constants/error_message.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/models/cash_balance.dart';
import 'package:bondgrid/models/payment_method_list.dart';
import 'package:bondgrid/models/transaction.dart';
import 'package:bondgrid/repo/transfer_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TransferStateStatus {
  initial,
  loading,
  success,
  failure,
}

class TransferState extends Equatable {
  final TransferStateStatus status;
  final String errorMessage;

  const TransferState(
      {this.status = TransferStateStatus.initial, this.errorMessage = ""});

  @override
  List<Object?> get props => [status, errorMessage];
}

class CreateDepositLoadingState extends TransferState {
  const CreateDepositLoadingState()
      : super(status: TransferStateStatus.loading);

  @override
  List<Object?> get props => [status];
}

class CreateDepositSuccessState extends TransferState {
  final Transaction transaction;

  const CreateDepositSuccessState({required this.transaction})
      : super(status: TransferStateStatus.success);

  @override
  List<Object?> get props => [status, transaction];
}

class CreateWithdrawalLoadingState extends TransferState {
  const CreateWithdrawalLoadingState()
      : super(status: TransferStateStatus.loading);

  @override
  List<Object?> get props => [status];
}

class CreateWithdrawalSuccessState extends TransferState {
  final Transaction transaction;

  const CreateWithdrawalSuccessState({required this.transaction})
      : super(status: TransferStateStatus.success);

  @override
  List<Object?> get props => [status];
}

class PaymentMethodLoadingState extends TransferState {
  const PaymentMethodLoadingState()
      : super(status: TransferStateStatus.loading);

  @override
  List<Object?> get props => [status];
}

class PaymentMethodSuccessState extends TransferState {
  final PaymentMethodList paymentMethods;

  const PaymentMethodSuccessState({required this.paymentMethods})
      : super(status: TransferStateStatus.success);

  @override
  List<Object?> get props => [status, errorMessage, paymentMethods];
}

class GetCashBalanceSuccessState extends TransferState {
  final CashBalance cashBalance;

  const GetCashBalanceSuccessState({required this.cashBalance})
      : super(status: TransferStateStatus.success);

  @override
  List<Object> get props => [cashBalance];
}

class LoadWithdrawalInitialDataLoadingState extends TransferState {
  const LoadWithdrawalInitialDataLoadingState()
      : super(status: TransferStateStatus.loading);

  @override
  List<Object?> get props => [status];
}

class LoadWithdrawalInitialDataSuccessState extends TransferState {
  final CashBalance cashBalance;
  final PaymentMethodList paymentMethods;

  const LoadWithdrawalInitialDataSuccessState(
      {required this.cashBalance, required this.paymentMethods})
      : super(status: TransferStateStatus.success);

  @override
  List<Object> get props => [cashBalance, paymentMethods];
}

class FailureState extends TransferState {
  const FailureState(String errorMessage)
      : super(status: TransferStateStatus.failure, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}

class TransferEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateDepositEvent extends TransferEvent {
  final String amount;
  final String paymentMethodId;

  CreateDepositEvent(this.amount, this.paymentMethodId);
}

class CreateWithdrawalEvent extends TransferEvent {
  final String amount;
  final String paymentMethodId;

  CreateWithdrawalEvent(this.amount, this.paymentMethodId);
}

class GetPaymentMethodsEvent extends TransferEvent {
  GetPaymentMethodsEvent();
}

class GetCashBalanceEvent extends TransferEvent {
  GetCashBalanceEvent();
}

class LoadWithdrawalInitialDataEvent extends TransferEvent {
  LoadWithdrawalInitialDataEvent();
}

extension on TransferBloc {
  void _handleError(dynamic error, Emitter<TransferState> emit) {
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

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferRepo transferRepo;

  TransferBloc(this.transferRepo) : super(const TransferState()) {
    on<CreateDepositEvent>((event, emit) async {
      emit(const CreateDepositLoadingState());
      try {
        Transaction response = await transferRepo.createDeposit(
            event.amount, event.paymentMethodId);
        emit(CreateDepositSuccessState(transaction: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<CreateWithdrawalEvent>((event, emit) async {
      //emit(const TransferState(status: TransferStateStatus.loading));
      emit(const CreateWithdrawalLoadingState());
      try {
        Transaction response = await transferRepo.createWithdrawal(
            event.amount, event.paymentMethodId);
        emit(CreateWithdrawalSuccessState(transaction: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetPaymentMethodsEvent>((event, emit) async {
      emit(const PaymentMethodLoadingState());
      try {
        PaymentMethodList response = await transferRepo.getPaymentMethods();
        emit(PaymentMethodSuccessState(paymentMethods: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<GetCashBalanceEvent>((event, emit) async {
      emit(const TransferState(status: TransferStateStatus.loading));
      try {
        CashBalance response = await transferRepo.getCashBalance();
        emit(GetCashBalanceSuccessState(cashBalance: response));
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<LoadWithdrawalInitialDataEvent>((event, emit) async {
      emit(const LoadWithdrawalInitialDataLoadingState());
      try {
        // Fetch payment methods and cash balance concurrently
        final futurePaymentMethods = transferRepo.getPaymentMethods();
        final futureCashBalance = transferRepo.getCashBalance();

        final results =
            await Future.wait([futurePaymentMethods, futureCashBalance]);

        PaymentMethodList paymentMethods = results[0] as PaymentMethodList;
        CashBalance cashBalance = results[1] as CashBalance;

        emit(LoadWithdrawalInitialDataSuccessState(
            paymentMethods: paymentMethods, cashBalance: cashBalance));
      } catch (error) {
        _handleError(error, emit);
      }
    });
  }
}
