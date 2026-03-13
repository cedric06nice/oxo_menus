import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/repositories/connectivity_repository.dart';

typedef DnsProbe = Future<bool> Function();

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  final Connectivity connectivity;
  final DnsProbe _dnsProbe;

  static const _dnsRetries = 2; // total 3 attempts
  static const _periodicProbeInterval = Duration(seconds: 30);
  static const _recoveryProbeInterval = Duration(seconds: 5);

  ConnectivityRepositoryImpl({required this.connectivity, DnsProbe? dnsProbe})
    : _dnsProbe = dnsProbe ?? _defaultDnsProbe;

  static Future<bool> _defaultDnsProbe() async {
    try {
      final results = await InternetAddress.lookup(
        'dns.google',
      ).timeout(const Duration(seconds: 3));
      return results.isNotEmpty && results.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _hasInternetAccess() async {
    for (int attempt = 0; attempt <= _dnsRetries; attempt++) {
      if (await _dnsProbe()) return true;
    }
    return false;
  }

  bool _hasNetworkInterface(List<ConnectivityResult> results) {
    return results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);
  }

  @override
  Future<ConnectivityStatus> checkConnectivity() async {
    final results = await connectivity.checkConnectivity();
    if (!_hasNetworkInterface(results)) return ConnectivityStatus.offline;
    final reachable = await _hasInternetAccess();
    return reachable ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }

  @override
  Stream<ConnectivityStatus> watchConnectivity() {
    late StreamController<ConnectivityStatus> controller;
    StreamSubscription<List<ConnectivityResult>>? subscription;
    Timer? periodicProbe;
    Timer? recoveryProbe;
    bool isProbing = false;

    void stopAllProbes() {
      periodicProbe?.cancel();
      periodicProbe = null;
      recoveryProbe?.cancel();
      recoveryProbe = null;
    }

    late void Function() startPeriodicProbe;
    late void Function() startRecoveryProbe;

    startRecoveryProbe = () {
      stopAllProbes();
      recoveryProbe = Timer.periodic(_recoveryProbeInterval, (_) async {
        if (isProbing) return;
        isProbing = true;
        try {
          final reachable = await _hasInternetAccess();
          if (reachable && !controller.isClosed) {
            controller.add(ConnectivityStatus.online);
            startPeriodicProbe();
          }
        } finally {
          isProbing = false;
        }
      });
    };

    startPeriodicProbe = () {
      stopAllProbes();
      periodicProbe = Timer.periodic(_periodicProbeInterval, (_) async {
        if (isProbing) return;
        isProbing = true;
        try {
          final reachable = await _hasInternetAccess();
          final status = reachable
              ? ConnectivityStatus.online
              : ConnectivityStatus.offline;
          if (!controller.isClosed) controller.add(status);
          if (!reachable) startRecoveryProbe();
        } finally {
          isProbing = false;
        }
      });
    };

    controller = StreamController<ConnectivityStatus>(
      onListen: () {
        checkConnectivity().then((status) {
          controller.add(status);
          if (status == ConnectivityStatus.online) startPeriodicProbe();
        }, onError: (_) => controller.add(ConnectivityStatus.online));

        subscription = connectivity.onConnectivityChanged.listen((
          results,
        ) async {
          if (!_hasNetworkInterface(results)) {
            stopAllProbes();
            controller.add(ConnectivityStatus.offline);
          } else {
            final reachable = await _hasInternetAccess();
            final status = reachable
                ? ConnectivityStatus.online
                : ConnectivityStatus.offline;
            if (!controller.isClosed) controller.add(status);
            if (reachable) {
              startPeriodicProbe();
            } else {
              startRecoveryProbe();
            }
          }
        }, onError: controller.addError);
      },
      onCancel: () {
        subscription?.cancel();
        stopAllProbes();
      },
    );

    return controller.stream.distinct();
  }
}
