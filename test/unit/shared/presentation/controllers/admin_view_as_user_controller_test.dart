import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/shared/presentation/controllers/admin_view_as_user_controller.dart';

import '../../../../fakes/reflectable_bootstrap.dart';

void main() {
  setUpAll(initializeReflectableForTests);

  group('AdminViewAsUserController', () {
    late AdminViewAsUserGateway gateway;

    setUp(() => gateway = AdminViewAsUserGateway());
    tearDown(() => gateway.dispose());

    test('initial value mirrors the gateway snapshot', () {
      final controller = AdminViewAsUserController(gateway: gateway);
      addTearDown(controller.dispose);

      expect(controller.value, isFalse);
    });

    test('set forwards to the gateway and notifies listeners', () async {
      final controller = AdminViewAsUserController(gateway: gateway);
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.set(true);
      await Future<void>.delayed(Duration.zero);

      expect(controller.value, isTrue);
      expect(gateway.currentValue, isTrue);
      expect(notifications, 1);
    });

    test('toggle flips the value', () async {
      final controller = AdminViewAsUserController(gateway: gateway);
      addTearDown(controller.dispose);

      controller.toggle();
      await Future<void>.delayed(Duration.zero);
      expect(controller.value, isTrue);

      controller.toggle();
      await Future<void>.delayed(Duration.zero);
      expect(controller.value, isFalse);
    });

    test('mirrors external gateway updates', () async {
      final controller = AdminViewAsUserController(gateway: gateway);
      addTearDown(controller.dispose);

      gateway.set(true);
      await Future<void>.delayed(Duration.zero);

      expect(controller.value, isTrue);
    });

    test('does not notify after dispose', () async {
      final controller = AdminViewAsUserController(gateway: gateway);

      var notifications = 0;
      controller.addListener(() => notifications++);
      controller.dispose();

      gateway.set(true);
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 0);
    });

    test('disposing twice is safe', () {
      final controller = AdminViewAsUserController(gateway: gateway);

      controller.dispose();

      expect(controller.dispose, returnsNormally);
    });
  });
}
