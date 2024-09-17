import 'dart:async';

import 'package:finvest/domain/interfaces/i_connection_aware_facade.dart';
import 'package:finvest/infrastructure/api_services/logger.dart';
import 'package:finvest/presentation/application/models/connection_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'base_event.dart';
part 'base_state.dart';

abstract class BaseBloc<Event extends BaseEvent, State extends BaseState,
    Store extends BaseStateStore> extends Bloc<BaseEvent, BaseState> {
  final IConnectionAwareFacade _networkHandlerFacade;
  late StreamSubscription _networkChangeSubscription;

  BaseBloc(
    this._networkHandlerFacade,
    Store _store,
  ) : super(InitialState(_store)) {
    if (!isClosed) {
      handleEvents();
    }

    _networkChangeSubscription = _networkHandlerFacade.connectionStatusStream
        .listen((status) => onConnectivityStatusChange(status: status));
  }

  @mustCallSuper
  void handleEvents() {
    on<OnStart>(_onStart);
    on<ChangeLoaderStatus>(_changeLoaderStatus);
    on<OnConnectionStatusChange>(_handleConnectivityChange);
    on<OnError>(_onError);
  }

  void _onStart(
    _,
    Emitter<BaseState> emit,
  ) {
    emit(InitialState(state.store));
  }

  void _changeLoaderStatus(
    ChangeLoaderStatus status,
    Emitter<BaseState> emit,
  ) {
    emit(
      LoaderState(
        state.store,
        status.loading,
      ),
    );
  }

  void _handleConnectivityChange(
    OnConnectionStatusChange event,
    Emitter<BaseState> emit,
  ) {
    emit(
      ConnectivityState(state.store, event.status),
    );
  }

  void _onError(
    OnError event,
    Emitter<BaseState> emit,
  ) {
    emit(
      ExceptionState(
        state.store,
        event.exception,
      ),
    );
  }

  void onConnectivityStatusChange({
    required ConnectionStatus status,
  }) {
    add(
      OnConnectionStatusChange(
        status: status,
      ),
    );
  }

  @mustCallSuper
  void started([
    Map<String, dynamic>? args,
  ]) {
    add(OnStart());
  }

  void invalidateLoader(
    Emitter<State> emit, {
    bool loading = false,
  }) {
    emit(
      state.getLoaderState(
        loading: loading,
      ) as State,
    );
  }

  void handleException(
    Emitter<State> emit,
    Exception exception,
  ) {
    emit(
      state.getExceptionState(
        exception,
      ) as State,
    );
  }

  @override
  void onTransition(
    Transition<BaseEvent, BaseState> transition,
  ) {
    logger
      ..d('Event: ${transition.event}')
      ..d('Current State: ${transition.currentState}')
      ..d('Next State ${transition.nextState}');
    super.onTransition(transition);
  }

  @override
  Future<void> close() async {
    await _networkChangeSubscription.cancel();
    return super.close();
  }
}
