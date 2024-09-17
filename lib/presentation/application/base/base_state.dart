part of 'base_bloc.dart';

abstract class BaseState {
  final BaseStateStore store;

  const BaseState(this.store);

  BaseState getExceptionState(
    Exception exception,
  ) {
    return ExceptionState(store, exception);
  }

  BaseState getLoaderState({
    required bool loading,
  }) {
    return LoaderState(store, loading);
  }
}

final class InitialState extends BaseState {
  const InitialState(super.store);
}

final class ConnectivityState extends BaseState {
  final ConnectionStatus status;

  const ConnectivityState(
    super.store,
    this.status,
  );
}

final class LoaderState extends BaseState {
  final bool loading;

  const LoaderState(
    super.store,
    this.loading,
  );
}

final class ExceptionState extends BaseState {
  final Exception exception;

  const ExceptionState(
    super.store,
    this.exception,
  );
}

class BaseStateStore {}
