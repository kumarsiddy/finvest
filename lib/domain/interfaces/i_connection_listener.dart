import 'package:bondgrid/domain/models/connection_status.dart';

abstract class IConnectionListener {
  Stream<ConnectionStatus> get connectionStatusStream;

  /// Checks if device has active internet connection or not.
  Future<ConnectionStatus> checkConnection();

  Future<void> updateConnectionStatus();
}
