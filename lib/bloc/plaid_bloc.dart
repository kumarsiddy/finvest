import 'dart:async';

import 'package:bondgrid/constants/error_message.dart';
import 'package:bondgrid/models/api_exception.dart';
import 'package:bondgrid/repo/plaid_repo.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

enum PlaidStateStatus {
  initial,
  loading,
  success,
  failure,
}

class PlaidState extends Equatable {
  final PlaidStateStatus status;
  final String errorMessage;

  const PlaidState(
      {this.status = PlaidStateStatus.initial, this.errorMessage = ""});

  @override
  List<Object?> get props => [status, errorMessage];
}

class GetPlaidLinkTokenSuccessState extends PlaidState {
  final String linkToken;

  const GetPlaidLinkTokenSuccessState({required this.linkToken})
      : super(status: PlaidStateStatus.success);

  @override
  List<Object?> get props => [status, errorMessage, linkToken];
}

class ExchangePlaidPublicTokenSuccessState extends PlaidState {
  const ExchangePlaidPublicTokenSuccessState()
      : super(status: PlaidStateStatus.success);

  @override
  List<Object?> get props => [status];
}

class FailureState extends PlaidState {
  const FailureState(String errorMessage)
      : super(status: PlaidStateStatus.failure, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}

class PlaidEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializePlaid extends PlaidEvent {}

class PlaidLinkEventOccurred extends PlaidEvent {
  final LinkEvent event;

  PlaidLinkEventOccurred(this.event);
}

class PlaidLinkExited extends PlaidEvent {
  final LinkExit event;

  PlaidLinkExited(this.event);
}

class PlaidLinkSuccessEvent extends PlaidEvent {
  final LinkSuccess event;

  PlaidLinkSuccessEvent(this.event);
}

class DisposePlaid extends PlaidEvent {}

class GetPlaidLinkTokenEvent extends PlaidEvent {
  final String platform;

  GetPlaidLinkTokenEvent(this.platform);
}

class ExchangePlaidPublicTokenEvent extends PlaidEvent {
  final Map<String, dynamic> linkData;

  ExchangePlaidPublicTokenEvent(this.linkData);
}

extension on PlaidBloc {
  void _handleError(dynamic error, Emitter<PlaidState> emit) {
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

class PlaidBloc extends Bloc<PlaidEvent, PlaidState> {
  final PlaidRepo plaidRepo;

  StreamSubscription<LinkEvent>? _streamEvent;
  StreamSubscription<LinkExit>? _streamExit;
  StreamSubscription<LinkSuccess>? _streamSuccess;

  PlaidBloc(this.plaidRepo) : super(const PlaidState()) {
    on<InitializePlaid>(_onInitializePlaid);
    on<PlaidLinkEventOccurred>(_onPlaidEvent);
    on<PlaidLinkExited>(_onPlaidExit);
    on<PlaidLinkSuccessEvent>(_onPlaidSuccess);
    on<DisposePlaid>(_onDisposePlaid);

    on<GetPlaidLinkTokenEvent>((event, emit) async {
      emit(const PlaidState(status: PlaidStateStatus.loading));
      try {
        Map<String, dynamic> response =
            await plaidRepo.getPlaidLinkToken(event.platform);
        if (response.containsKey('link_token') &&
            response['link_token'] != null) {
          emit(
              GetPlaidLinkTokenSuccessState(linkToken: response['link_token']));
        } else {
          emit(const FailureState("Link token is not present in response"));
        }
      } catch (error) {
        _handleError(error, emit);
      }
    });

    on<ExchangePlaidPublicTokenEvent>((event, emit) async {
      emit(const PlaidState(status: PlaidStateStatus.loading));
      try {
        await plaidRepo.exchangePlaidPublicToken(event.linkData);
        emit(const ExchangePlaidPublicTokenSuccessState());
      } catch (error) {
        _handleError(error, emit);
      }
    });
  }

  void _onInitializePlaid(InitializePlaid event, Emitter<PlaidState> emit) {
    _streamEvent = PlaidLink.onEvent.listen((event) {
      add(PlaidLinkEventOccurred(event));
    });
    _streamExit = PlaidLink.onExit.listen((event) {
      add(PlaidLinkExited(event));
    });
    _streamSuccess = PlaidLink.onSuccess.listen((event) {
      add(PlaidLinkSuccessEvent(event));
    });
  }

  void _onPlaidEvent(PlaidLinkEventOccurred event, Emitter<PlaidState> emit) {
    final name = event.event.name;
    final metadata = event.event.metadata.description();
    // print("onEvent: $name, metadata: $metadata");
  }

  void _onPlaidExit(PlaidLinkExited event, Emitter<PlaidState> emit) {
    final metadata = event.event.metadata.description();
    final error = event.event.error?.description();
    emit(const FailureState("Failure in adding bank account"));
  }

  void _onPlaidSuccess(PlaidLinkSuccessEvent event, Emitter<PlaidState> emit) {
    emit(const PlaidState(status: PlaidStateStatus.loading));
    add(ExchangePlaidPublicTokenEvent(getPlaidLinkJson(event.event)));
  }

  void _onDisposePlaid(DisposePlaid event, Emitter<PlaidState> emit) {
    _streamEvent?.cancel();
    _streamExit?.cancel();
    _streamSuccess?.cancel();
  }

  @override
  Future<void> close() {
    _streamEvent?.cancel();
    _streamExit?.cancel();
    _streamSuccess?.cancel();
    return super.close();
  }
}
