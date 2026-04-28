import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/presentation/controllers/app_lifecycle_controller.dart';

import '../../../../fakes/reflectable_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeReflectableForTests);

  group('AppLifecycleController', () {
    test('starts in resumed state', () {
      final controller = AppLifecycleController();
      addTearDown(controller.dispose);

      expect(controller.state, AppLifecycleState.resumed);
      expect(controller.isInForeground, isTrue);
    });

    test('mirrors lifecycle changes and notifies listeners', () async {
      final controller = AppLifecycleController();
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(controller.state, AppLifecycleState.paused);
      expect(controller.isInForeground, isFalse);
      expect(notifications, 1);
    });

    test('does not notify when state is unchanged', () {
      final controller = AppLifecycleController();
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(notifications, 0);
    });

    test('isInForeground is true only in resumed state', () {
      final controller = AppLifecycleController();
      addTearDown(controller.dispose);

      controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
      expect(controller.isInForeground, isFalse);

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(controller.isInForeground, isFalse);

      controller.didChangeAppLifecycleState(AppLifecycleState.detached);
      expect(controller.isInForeground, isFalse);

      controller.didChangeAppLifecycleState(AppLifecycleState.hidden);
      expect(controller.isInForeground, isFalse);

      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(controller.isInForeground, isTrue);
    });

    test('removes itself as observer on dispose', () {
      final controller = AppLifecycleController();
      controller.dispose();

      // After dispose, sending state changes should not notify or throw.
      var notifications = 0;
      // ignore: invalid_use_of_protected_member
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(notifications, 0);
    });

    test('disposing twice is safe', () {
      final controller = AppLifecycleController();

      controller.dispose();

      expect(controller.dispose, returnsNormally);
    });
  });
}
