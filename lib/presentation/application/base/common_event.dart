part of 'base_bloc.dart';

sealed class CommonEvent {}

final class OnStart extends CommonEvent {
  final Map<String, dynamic>? args;

  OnStart(this.args);
}

final class ChangeLoaderStatus extends CommonEvent {
  final bool loading;

  ChangeLoaderStatus({
    required this.loading,
  });
}

final class OnConnectionStatusChange extends CommonEvent {
  final ConnectionStatus status;

  OnConnectionStatusChange({
    required this.status,
  });
}

final class OnError extends CommonEvent {
  final Exception exception;

  OnError({
    required this.exception,
  });
}
