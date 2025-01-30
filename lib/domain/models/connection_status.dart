import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionStatus {
  final bool working;

  const ConnectionStatus({
    required final ConnectivityResult connectivityResult,
    this.working = false,
  });
}
