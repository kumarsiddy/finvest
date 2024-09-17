part of 'base_bloc.dart';

abstract class BaseEvent {}

final class OnStart extends BaseEvent {}

final class ChangeLoaderStatus extends BaseEvent {
  final bool loading;

  ChangeLoaderStatus({
    required this.loading,
  });
}

final class OnConnectionStatusChange extends BaseEvent {
  final ConnectionStatus status;

  OnConnectionStatusChange({
    required this.status,
  });
}

final class OnError extends BaseEvent {
  final Exception exception;

  OnError({
    required this.exception,
  });
}
