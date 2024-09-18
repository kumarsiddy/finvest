import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_status.freezed.dart';

@freezed
class ConnectionStatus with _$ConnectionStatus {
  const factory ConnectionStatus({
    required final ConnectivityResult type,
    @Default(true) final bool working,
  }) = _ConnectionStatus;
}
