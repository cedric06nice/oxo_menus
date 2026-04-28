import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:oxo_menus/shared/presentation/controllers/connectivity_controller.dart';

import '../../../../fakes/reflectable_bootstrap.dart';

class _FakeConnectivityRepository implements ConnectivityRepository {
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();
  ConnectivityStatus probeResult = ConnectivityStatus.online;
  int checkCalls = 0;

  @override
  Stream<ConnectivityStatus> watchConnectivity() => controller.stream;

  @override
  Future<ConnectivityStatus> checkConnectivity() async {
    checkCalls++;
    return probeResult;
  }
}

void main() {
  setUpAll(initializeReflectableForTests);

  group('ConnectivityController', () {
    late _FakeConnectivityRepository repo;
    late ConnectivityGateway gateway;

    setUp(() {
      repo = _FakeConnectivityRepository();
      gateway = ConnectivityGateway(repository: repo);
    });

    tearDown(() => gateway.dispose());

    test('initial status mirrors the gateway snapshot', () {
      final controller = ConnectivityController(gateway: gateway);
      addTearDown(controller.dispose);

      expect(controller.status, ConnectivityStatus.online);
      expect(controller.isOffline, isFalse);
    });

    test('mirrors gateway transitions and notifies listeners', () async {
      final controller = ConnectivityController(gateway: gateway);
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      repo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(controller.status, ConnectivityStatus.offline);
      expect(controller.isOffline, isTrue);
      expect(notifications, 1);
    });

    test('does not notify when status is unchanged', () async {
      final controller = ConnectivityController(gateway: gateway);
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      repo.controller.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 0);
    });

    test('recheck delegates to the gateway probe', () async {
      final controller = ConnectivityController(gateway: gateway);
      addTearDown(controller.dispose);

      repo.probeResult = ConnectivityStatus.offline;
      await controller.recheck();
      await Future<void>.delayed(Duration.zero);

      expect(controller.status, ConnectivityStatus.offline);
      expect(repo.checkCalls, greaterThanOrEqualTo(1));
    });

    test('does not notify after dispose', () async {
      final controller = ConnectivityController(gateway: gateway);

      var notifications = 0;
      controller.addListener(() => notifications++);
      controller.dispose();

      repo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 0);
    });

    test('disposing twice is safe', () {
      final controller = ConnectivityController(gateway: gateway);

      controller.dispose();

      expect(controller.dispose, returnsNormally);
    });
  });
}
