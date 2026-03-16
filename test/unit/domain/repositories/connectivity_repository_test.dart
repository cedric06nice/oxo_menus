import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/domain/repositories/connectivity_repository.dart';

class _FakeConnectivityRepository implements ConnectivityRepository {
  @override
  Stream<ConnectivityStatus> watchConnectivity() =>
      Stream.value(ConnectivityStatus.online);

  @override
  Future<ConnectivityStatus> checkConnectivity() async =>
      ConnectivityStatus.online;
}

void main() {
  group('ConnectivityRepository', () {
    test('can be implemented', () {
      final repo = _FakeConnectivityRepository();
      expect(repo, isA<ConnectivityRepository>());
    });

    test('watchConnectivity returns a stream of ConnectivityStatus', () async {
      final repo = _FakeConnectivityRepository();
      final result = await repo.watchConnectivity().first;
      expect(result, ConnectivityStatus.online);
    });

    test('checkConnectivity returns a Future of ConnectivityStatus', () async {
      final repo = _FakeConnectivityRepository();
      final result = await repo.checkConnectivity();
      expect(result, ConnectivityStatus.online);
    });
  });
}
