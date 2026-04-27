import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/gateways/app_version_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/get_app_version_use_case.dart';

class _FakeAppVersionGateway implements AppVersionGateway {
  String value = '1.0.0';
  Object? failure;
  int calls = 0;

  @override
  Future<String> read() async {
    calls++;
    if (failure != null) {
      throw failure!;
    }
    return value;
  }
}

void main() {
  group('GetAppVersionUseCase', () {
    test('returns the gateway value as Success', () async {
      final gateway = _FakeAppVersionGateway()..value = '1.2.3 (42)';
      final useCase = GetAppVersionUseCase(gateway: gateway);

      final result = await useCase.execute(NoInput.instance);

      expect(result, isA<Success<String, Object>>());
      result.fold(
        onSuccess: (v) => expect(v, '1.2.3 (42)'),
        onFailure: (_) => fail('expected success'),
      );
      expect(gateway.calls, 1);
    });

    test('wraps gateway exceptions as a Failure (UnknownError)', () async {
      final gateway = _FakeAppVersionGateway()..failure = StateError('boom');
      final useCase = GetAppVersionUseCase(gateway: gateway);

      final result = await useCase.execute(NoInput.instance);

      expect(result.isFailure, isTrue);
    });
  });
}
