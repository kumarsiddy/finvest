import 'dart:async';
import 'dart:io';

import 'package:bondgrid/domain/interfaces/i_connection_listener.dart';
import 'package:bondgrid/domain/models/connection_status.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@LazySingleton(as: IConnectionListener)
class ConnectionListener implements IConnectionListener {
  static const int _defaultPort = 53;
  static const Duration _defaultTimeOut = Duration(milliseconds: 3000);

  /// Predefined reliable addresses.
  /// but should be enough. See https://www.dnsperf.com/#!dns-resolvers
  ///
  /// Addresses info:
  ///
  /// <!-- kinda hackish ^_^ -->
  /// | Address        | Provider   | Info                                            |
  /// |:---------------|:-----------|:------------------------------------------------|
  /// | 1.1.1.1        | CloudFlare | https://1.1.1.1                                 |
  /// | 1.0.0.1        | CloudFlare | https://1.1.1.1                                 |
  /// | 8.8.8.8        | Google     | https://developers.google.com/speed/public-dns/ |
  /// | 8.8.4.4        | Google     | https://developers.google.com/speed/public-dns/ |
  /// | 208.67.222.222 | OpenDNS    | https://use.opendns.com/                        |
  /// | 208.67.220.220 | OpenDNS    | https://use.opendns.com/                        |
  static final List<_AddressCheckOptions> _defaultAddresses =
      List.unmodifiable([
    _AddressCheckOptions(
      InternetAddress('1.1.1.1'),
      port: _defaultPort,
      timeout: _defaultTimeOut,
    ),
    _AddressCheckOptions(
      InternetAddress('8.8.4.4'),
      port: _defaultPort,
      timeout: _defaultTimeOut,
    ),
    _AddressCheckOptions(
      InternetAddress('208.67.222.222'),
      port: _defaultPort,
      timeout: _defaultTimeOut,
    ),
  ]);

  // Stream broadcaster for userStatus
  final connectionStatusSubject = PublishSubject<ConnectionStatus>();

  final Connectivity _connectivity;

  ConnectionListener(
    this._connectivity,
  ) {
    _connectivity.onConnectivityChanged.listen(
      (_) async => updateConnectionStatus(),
    );
  }

  @override
  Stream<ConnectionStatus> get connectionStatusStream =>
      connectionStatusSubject.stream.doOnListen(updateConnectionStatus);

  @override
  Future<void> updateConnectionStatus() async {
    final connectionStatus = await checkConnection();
    connectionStatusSubject.sink.add(connectionStatus);
  }

  @override
  Future<ConnectionStatus> checkConnection() async {
    final requests = <Future<bool>>[];

    for (final addressOption in _defaultAddresses) {
      requests.add(_isHostReachable(addressOption));
    }
    final results = List.unmodifiable(await Future.wait(requests));
    final working = results.contains(true);
    return ConnectionStatus(
      connectivityResult: await _connectivity.checkConnectivity(),
      working: working,
    );
  }

  Future<bool> _isHostReachable(
    _AddressCheckOptions options,
  ) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        options.address,
        options.port ?? _defaultPort,
        timeout: options.timeout ?? _defaultTimeOut,
      )
        ..destroy();
      return true;
    } catch (e) {
      socket?.destroy();
      return false;
    }
  }
}

class _AddressCheckOptions {
  final InternetAddress address;
  final int? port;
  final Duration? timeout;

  _AddressCheckOptions(
    this.address, {
    this.port,
    this.timeout,
  });

  @override
  String toString() => '''AddressCheckOptions($address, $port, $timeout)''';
}
