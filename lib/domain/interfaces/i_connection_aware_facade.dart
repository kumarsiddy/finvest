import 'package:finvest/presentation/application/models/connection_status.dart';

abstract class IConnectionAwareFacade {
  Stream<ConnectionStatus> get connectionStatusStream;

  /// Checks if device has active internet connection or not.
  Future<ConnectionStatus> checkConnection();

  Future<void> updateConnectionStatus();
}
