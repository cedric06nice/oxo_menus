import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/connectivity_status.dart';

void main() {
  group('ConnectivityStatus', () {
    test('has online value', () {
      expect(ConnectivityStatus.online, isNotNull);
    });

    test('has offline value', () {
      expect(ConnectivityStatus.offline, isNotNull);
    });

    test('has exactly two values', () {
      expect(ConnectivityStatus.values, hasLength(2));
    });

    test('values are distinct', () {
      expect(ConnectivityStatus.online, isNot(ConnectivityStatus.offline));
    });
  });
}
