import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/lock_widget_for_editing_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/unlock_widget_use_case.dart';

import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

void main() {
  group('LockWidgetForEditingUseCase', () {
    test('forwards input to the repository', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()
        ..whenLockForEditing(const Success(null));
      final useCase = LockWidgetForEditingUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      await useCase.execute(
        const LockWidgetForEditingInput(widgetId: 7, userId: 'u-1'),
      );

      final lock = repo.calls.single as WidgetLockForEditingCall;
      expect(lock.widgetId, 7);
      expect(lock.userId, 'u-1');
    });

    test('returns UnauthorizedError when anonymous', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = LockWidgetForEditingUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(
        const LockWidgetForEditingInput(widgetId: 7, userId: 'u-1'),
      );

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });

  group('UnlockWidgetUseCase', () {
    test('forwards id to the repository', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()
        ..whenUnlockEditing(const Success(null));
      final useCase = UnlockWidgetUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      await useCase.execute(7);

      final unlock = repo.calls.single as WidgetUnlockEditingCall;
      expect(unlock.widgetId, 7);
    });

    test('returns UnauthorizedError when anonymous', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = UnlockWidgetUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(7);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });

  group('LockWidgetForEditingInput', () {
    test('value-equal inputs hash to the same bucket', () {
      const a = LockWidgetForEditingInput(widgetId: 1, userId: 'u-1');
      const b = LockWidgetForEditingInput(widgetId: 1, userId: 'u-1');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
