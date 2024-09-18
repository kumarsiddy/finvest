import 'dart:async';

import 'package:finvest/domain/interfaces/i_connection_aware_facade.dart';
import 'package:finvest/presentation/application/base/base_bloc.dart';
import 'package:finvest/presentation/application/models/connection_status.dart';
import 'package:finvest/presentation/application/models/state_stores.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class CommonBloc extends Bloc<CommonEvent, CommonState> {
  final IConnectionAwareFacade _networkHandlerFacade;
  late StreamSubscription _networkChangeSubscription;

  CommonBloc(
    this._networkHandlerFacade,
  ) : super(InitialState(CommonStore(args: null))) {
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
    emit(ArgsLoadedState(state.store.copyWith(args: event.args)));
  }

  void _changeLoaderStatus(
    ChangeLoaderStatus status,
    Emitter<CommonState> emit,
  ) {
    emit(
      LoaderState(state.store, status.loading),
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

  void init([
    Map<String, dynamic>? args,
  ]) {
    add(OnStart(args));
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
