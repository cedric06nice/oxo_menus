import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/connectivity/domain/repositories/connectivity_repository.dart';

class _StubConnectivityRepository implements ConnectivityRepository {
  _StubConnectivityRepository({this.initialStatus = ConnectivityStatus.online});

  final ConnectivityStatus initialStatus;
  final StreamController<ConnectivityStatus> controller =
      StreamController<ConnectivityStatus>.broadcast();
  int watchCalls = 0;
  int checkCalls = 0;

  @override
  Stream<ConnectivityStatus> watchConnectivity() {
    watchCalls++;
    return controller.stream;
  }

  @override
  Future<ConnectivityStatus> checkConnectivity() async {
    checkCalls++;
    return initialStatus;
  }

  Future<void> close() => controller.close();
}

void main() {
  group('ConnectivityGateway', () {
    test(
      'caches the initial probe in currentStatus without emitting it',
      () async {
        final repo = _StubConnectivityRepository(
          initialStatus: ConnectivityStatus.offline,
        );
        final gateway = ConnectivityGateway(repository: repo);
        addTearDown(gateway.dispose);
        addTearDown(repo.close);

        final received = <ConnectivityStatus>[];
        final sub = gateway.statusStream.listen(received.add);
        addTearDown(sub.cancel);
        await Future<void>.delayed(Duration.zero);

        expect(gateway.currentStatus, ConnectivityStatus.offline);
        expect(received, isEmpty);
        expect(repo.checkCalls, 1);
        expect(repo.watchCalls, 1);
      },
    );

    test('forwards repository events through statusStream', () async {
      final repo = _StubConnectivityRepository();
      final gateway = ConnectivityGateway(repository: repo);
      addTearDown(gateway.dispose);
      addTearDown(repo.close);

      final received = <ConnectivityStatus>[];
      final sub = gateway.statusStream.listen(received.add);
      addTearDown(sub.cancel);

      repo.controller.add(ConnectivityStatus.offline);
      repo.controller.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(received, [ConnectivityStatus.offline, ConnectivityStatus.online]);
    });

    test('updates currentStatus as repository events arrive', () async {
      final repo = _StubConnectivityRepository();
      final gateway = ConnectivityGateway(repository: repo);
      addTearDown(gateway.dispose);
      addTearDown(repo.close);

      repo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(gateway.currentStatus, ConnectivityStatus.offline);

      repo.controller.add(ConnectivityStatus.online);
      await Future<void>.delayed(Duration.zero);

      expect(gateway.currentStatus, ConnectivityStatus.online);
    });

    test('statusStream is broadcast — supports multiple listeners', () async {
      final repo = _StubConnectivityRepository();
      final gateway = ConnectivityGateway(repository: repo);
      addTearDown(gateway.dispose);
      addTearDown(repo.close);

      final a = <ConnectivityStatus>[];
      final b = <ConnectivityStatus>[];
      final subA = gateway.statusStream.listen(a.add);
      final subB = gateway.statusStream.listen(b.add);
      addTearDown(subA.cancel);
      addTearDown(subB.cancel);

      repo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(a, [ConnectivityStatus.offline]);
      expect(b, [ConnectivityStatus.offline]);
    });

    test('dispose cancels the repository subscription and closes the '
        'controller', () async {
      final repo = _StubConnectivityRepository();
      final gateway = ConnectivityGateway(repository: repo);
      addTearDown(repo.close);

      gateway.dispose();

      expect(gateway.isDisposed, isTrue);
      // Adding after dispose must not throw or notify.
      repo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);
    });

    test('dispose is idempotent', () async {
      final repo = _StubConnectivityRepository();
      final gateway = ConnectivityGateway(repository: repo);
      addTearDown(repo.close);

      gateway.dispose();
      gateway.dispose();

      expect(gateway.isDisposed, isTrue);
    });

    test('does not emit further events after dispose', () async {
      final repo = _StubConnectivityRepository();
      final gateway = ConnectivityGateway(repository: repo);
      addTearDown(repo.close);

      final received = <ConnectivityStatus>[];
      final sub = gateway.statusStream.listen(received.add);
      addTearDown(sub.cancel);

      gateway.dispose();
      repo.controller.add(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(received, isEmpty);
    });

    test('initial probe failure leaves currentStatus at online (optimistic '
        'default)', () async {
      final repo = _StubConnectivityRepository();
      final gateway = ConnectivityGateway(repository: repo);
      addTearDown(gateway.dispose);
      addTearDown(repo.close);

      // Before any event arrives.
      expect(gateway.currentStatus, ConnectivityStatus.online);
    });
  });
}
