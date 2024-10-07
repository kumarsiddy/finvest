part of 'base_bloc.dart';

sealed class CommonState {
  final CommonStore store;

  const CommonState(this.store);
}

final class InitialState extends CommonState {
  const InitialState(super.store);
}

final class ArgsLoadedState extends CommonState {
  const ArgsLoadedState(super.store);
}

final class ConnectivityState extends CommonState {
  final ConnectionStatus status;

  const ConnectivityState(
    super.store,
    this.status,
  );
}

final class LoaderState extends CommonState {
  final bool loading;

  const LoaderState(
    super.store,
    this.loading,
  );
}

final class ExceptionState extends CommonState {
  final Exception exception;

  const ExceptionState(
    super.store,
    this.exception,
  );
}
