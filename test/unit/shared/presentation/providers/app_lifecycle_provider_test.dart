import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/presentation/providers/app_lifecycle_provider.dart';

void main() {
  group('AppLifecycleNotifier', () {
    late ProviderContainer container;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should have resumed as initial state', () {
      expect(container.read(appLifecycleProvider), AppLifecycleState.resumed);
    });

    test('should update state to paused when lifecycle changes', () {
      container
          .read(appLifecycleProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(container.read(appLifecycleProvider), AppLifecycleState.paused);
    });

    test('should update state to inactive when lifecycle changes', () {
      container
          .read(appLifecycleProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.inactive);

      expect(container.read(appLifecycleProvider), AppLifecycleState.inactive);
    });

    test('should update state to hidden when lifecycle changes', () {
      container
          .read(appLifecycleProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.hidden);

      expect(container.read(appLifecycleProvider), AppLifecycleState.hidden);
    });

    test('should update state back to resumed from paused', () {
      final notifier = container.read(appLifecycleProvider.notifier);
      notifier.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(container.read(appLifecycleProvider), AppLifecycleState.paused);

      notifier.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(container.read(appLifecycleProvider), AppLifecycleState.resumed);
    });

    test('should notify listeners when state changes', () {
      final states = <AppLifecycleState>[];
      container.listen<AppLifecycleState>(
        appLifecycleProvider,
        (_, next) => states.add(next),
      );

      container
          .read(appLifecycleProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(states, [AppLifecycleState.paused]);
    });
  });

  group('isAppInForegroundProvider', () {
    late ProviderContainer container;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should return true when app is resumed', () {
      expect(container.read(isAppInForegroundProvider), isTrue);
    });

    test('should return false when app is paused', () {
      container
          .read(appLifecycleProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(container.read(isAppInForegroundProvider), isFalse);
    });

    test('should return false when app is inactive', () {
      container
          .read(appLifecycleProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.inactive);

      expect(container.read(isAppInForegroundProvider), isFalse);
    });

    test('should return false when app is hidden', () {
      container
          .read(appLifecycleProvider.notifier)
          .didChangeAppLifecycleState(AppLifecycleState.hidden);

      expect(container.read(isAppInForegroundProvider), isFalse);
    });

    test('should return true again after resuming from paused', () {
      final notifier = container.read(appLifecycleProvider.notifier);
      notifier.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(container.read(isAppInForegroundProvider), isFalse);

      notifier.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(container.read(isAppInForegroundProvider), isTrue);
    });

    test('should be derived from appLifecycleProvider state', () {
      // Override the lifecycle provider directly with a fixed paused state
      // to verify isAppInForegroundProvider derives from it.
      final container2 = ProviderContainer(
        overrides: [
          appLifecycleProvider.overrideWith(
            () => _FixedLifecycleNotifier(AppLifecycleState.paused),
          ),
        ],
      );
      addTearDown(container2.dispose);

      expect(container2.read(isAppInForegroundProvider), isFalse);
    });
  });
}

class _FixedLifecycleNotifier extends AppLifecycleNotifier {
  final AppLifecycleState _fixed;
  _FixedLifecycleNotifier(this._fixed);

  @override
  AppLifecycleState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return _fixed;
  }
}
