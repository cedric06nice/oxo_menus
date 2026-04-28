import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/gateways/app_version_gateway.dart';
import 'package:package_info_plus/package_info_plus.dart';

PackageInfo _info({required String version, required String buildNumber}) {
  return PackageInfo(
    appName: 'OXO',
    packageName: 'com.example.oxo',
    version: version,
    buildNumber: buildNumber,
  );
}

void main() {
  group('PackageInfoAppVersionGateway', () {
    test('formats "<version> (<build>)" when buildNumber is present', () async {
      final gateway = PackageInfoAppVersionGateway(
        reader: () async => _info(version: '1.2.3', buildNumber: '42'),
      );

      final result = await gateway.read();

      expect(result, '1.2.3 (42)');
    });

    test('returns just the version when buildNumber is empty', () async {
      final gateway = PackageInfoAppVersionGateway(
        reader: () async => _info(version: '0.9.0', buildNumber: ''),
      );

      final result = await gateway.read();

      expect(result, '0.9.0');
    });

    test('reader is invoked on every call (no internal caching)', () async {
      var calls = 0;
      final gateway = PackageInfoAppVersionGateway(
        reader: () async {
          calls++;
          return _info(version: '1.0.0', buildNumber: '');
        },
      );

      await gateway.read();
      await gateway.read();

      expect(calls, 2);
    });

    test('propagates errors thrown by the reader', () async {
      final gateway = PackageInfoAppVersionGateway(
        reader: () async => throw StateError('platform unavailable'),
      );

      expect(gateway.read(), throwsA(isA<StateError>()));
    });
  });
}
