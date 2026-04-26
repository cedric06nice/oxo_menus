import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/providers/app_version_provider.dart';

void main() {
  group('appVersionProvider', () {
    test('should be a FutureProvider of String', () {
      expect(appVersionProvider, isA<FutureProvider<String>>());
    });

    test(
      'should return the overridden version string when overridden',
      () async {
        final container = ProviderContainer(
          overrides: [
            appVersionProvider.overrideWith((_) async => '1.2.3 (45)'),
          ],
        );
        addTearDown(container.dispose);

        final version = await container.read(appVersionProvider.future);

        expect(version, '1.2.3 (45)');
      },
    );

    test(
      'should return version without build number when overridden without build number',
      () async {
        final container = ProviderContainer(
          overrides: [appVersionProvider.overrideWith((_) async => '1.0.0')],
        );
        addTearDown(container.dispose);

        final version = await container.read(appVersionProvider.future);

        expect(version, '1.0.0');
      },
    );

    test('should start in loading state before resolving', () {
      final container = ProviderContainer(
        overrides: [
          appVersionProvider.overrideWith((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return '1.0.0';
          }),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(appVersionProvider);

      expect(state, const AsyncValue<String>.loading());
    });

    test('should transition to data state after resolving', () async {
      final container = ProviderContainer(
        overrides: [
          appVersionProvider.overrideWith((_) async => '2.0.0 (100)'),
        ],
      );
      addTearDown(container.dispose);

      final version = await container.read(appVersionProvider.future);
      final state = container.read(appVersionProvider);

      expect(state.hasValue, isTrue);
      expect(state.value, version);
    });

    test('should transition to error state when resolution fails', () async {
      final container = ProviderContainer(
        overrides: [
          appVersionProvider.overrideWith((_) async {
            throw Exception('Platform info unavailable');
          }),
        ],
      );
      addTearDown(container.dispose);

      // Keep a subscription so the provider stays alive after the error
      final sub = container.listen(appVersionProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);

      final state = container.read(appVersionProvider);
      sub.close();

      expect(state.hasError, isTrue);
    });
  });
}
