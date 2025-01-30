import 'dart:async';

import 'package:bondgrid/domain/interfaces/i_connection_listener.dart';
import 'package:bondgrid/domain/models/connection_status.dart';
import 'package:bondgrid/presentation/base/base_bloc.dart';
import 'package:bondgrid/presentation/models/state_stores.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CommonBloc extends Bloc<CommonEvent, CommonState> {
  final IConnectionListener _networkHandlerFacade;
  late StreamSubscription _networkChangeSubscription;

  CommonBloc(
    this._networkHandlerFacade,
  ) : super(InitialState(CommonStore())) {
    if (!isClosed) {
      handleEvents();
    }

    _networkChangeSubscription = _networkHandlerFacade.connectionStatusStream
        .listen((status) => _onConnectivityStatusChange(status: status));
  }

  void handleEvents() {
    on<OnStart>(_onStart);
    on<ChangeLoaderStatus>(_changeLoaderStatus);
    on<OnConnectionStatusChange>(_handleConnectivityChange);
    on<OnError>(_onError);
  }

  void _onStart(
    OnStart event,
    Emitter<CommonState> emit,
  ) {
    emit(StartedState(state.store));
  }

  void _changeLoaderStatus(
    ChangeLoaderStatus event,
    Emitter<CommonState> emit,
  ) {
    emit(
      LoaderState(
        state.store.copyWith(
          loading: event.loading,
        ),
      ),
    );
  }

  void _handleConnectivityChange(
    OnConnectionStatusChange event,
    Emitter<CommonState> emit,
  ) {
    emit(
      ConnectivityState(state.store, event.status),
    );
  }

  void _onError(
    OnError event,
    Emitter<CommonState> emit,
  ) {
    emit(
      ExceptionState(state.store, event.exception),
    );
  }

  void _onConnectivityStatusChange({
    required ConnectionStatus status,
  }) {
    add(
      OnConnectionStatusChange(
        status: status,
      ),
    );
  }

  void init() {
    add(OnStart());
  }

  void invalidateLoader({
    bool loading = false,
  }) {
    add(ChangeLoaderStatus(loading: loading));
  }

  void handleException(
    Exception exception,
  ) {
    add(OnError(exception: exception));
  }

  @override
  Future<void> close() async {
    await _networkChangeSubscription.cancel();
    return super.close();
  }
}
