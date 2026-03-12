import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/providers/app_lifecycle_provider.dart';

void main() {
  group('AppLifecycleNotifier', () {
    late ProviderContainer container;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is resumed', () {
      final state = container.read(appLifecycleProvider);
      expect(state, AppLifecycleState.resumed);
    });

    test('updates state when didChangeAppLifecycleState is called', () {
      final notifier = container.read(appLifecycleProvider.notifier);
      notifier.didChangeAppLifecycleState(AppLifecycleState.paused);

      final state = container.read(appLifecycleProvider);
      expect(state, AppLifecycleState.paused);
    });

    test('updates to inactive state', () {
      final notifier = container.read(appLifecycleProvider.notifier);
      notifier.didChangeAppLifecycleState(AppLifecycleState.inactive);

      expect(container.read(appLifecycleProvider), AppLifecycleState.inactive);
    });
  });

  group('isAppInForegroundProvider', () {
    late ProviderContainer container;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('returns true when app is resumed', () {
      expect(container.read(isAppInForegroundProvider), true);
    });

    test('returns false when app is paused', () {
      container
          .read(appLifecycleProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(container.read(isAppInForegroundProvider), false);
    });

    test('returns false when app is inactive', () {
      container
          .read(appLifecycleProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.inactive);

      expect(container.read(isAppInForegroundProvider), false);
    });

    test('returns false when app is hidden', () {
      container
          .read(appLifecycleProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.hidden);

      expect(container.read(isAppInForegroundProvider), false);
    });

    test('returns true again when app is resumed after pause', () {
      final notifier = container.read(appLifecycleProvider.notifier);
      notifier.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(container.read(isAppInForegroundProvider), false);

      notifier.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(container.read(isAppInForegroundProvider), true);
    });
  });
}
