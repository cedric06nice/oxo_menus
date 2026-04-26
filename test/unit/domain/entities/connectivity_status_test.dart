import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';

void main() {
  group('ConnectivityStatus', () {
    group('values', () {
      test('should have exactly two cases', () {
        expect(ConnectivityStatus.values.length, 2);
      });

      test('should include online case', () {
        expect(ConnectivityStatus.values, contains(ConnectivityStatus.online));
      });

      test('should include offline case', () {
        expect(ConnectivityStatus.values, contains(ConnectivityStatus.offline));
      });
    });

    group('identity', () {
      test('should be equal to itself for online', () {
        expect(ConnectivityStatus.online, equals(ConnectivityStatus.online));
      });

      test('should be equal to itself for offline', () {
        expect(ConnectivityStatus.offline, equals(ConnectivityStatus.offline));
      });

      test('should not be equal to the other case', () {
        expect(
          ConnectivityStatus.online,
          isNot(equals(ConnectivityStatus.offline)),
        );
      });
    });

    group('name', () {
      test('should have name "online" for the online case', () {
        expect(ConnectivityStatus.online.name, 'online');
      });

      test('should have name "offline" for the offline case', () {
        expect(ConnectivityStatus.offline.name, 'offline');
      });
    });

    group('index', () {
      test('should have index 0 for online', () {
        expect(ConnectivityStatus.online.index, 0);
      });

      test('should have index 1 for offline', () {
        expect(ConnectivityStatus.offline.index, 1);
      });
    });

    group('toString', () {
      test('should produce a non-empty string for online', () {
        expect(ConnectivityStatus.online.toString(), isNotEmpty);
      });

      test('should produce a non-empty string for offline', () {
        expect(ConnectivityStatus.offline.toString(), isNotEmpty);
      });
    });
  });
}
