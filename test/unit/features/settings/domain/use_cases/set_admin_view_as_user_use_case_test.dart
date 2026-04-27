import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/gateways/admin_view_as_user_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/settings/domain/use_cases/set_admin_view_as_user_use_case.dart';

void main() {
  group('SetAdminViewAsUserUseCase', () {
    test('writes the value to the gateway and returns success', () {
      final gateway = AdminViewAsUserGateway();
      addTearDown(gateway.dispose);
      final useCase = SetAdminViewAsUserUseCase(gateway: gateway);

      final result = useCase.execute(true);

      expect(result.isSuccess, isTrue);
      expect(gateway.currentValue, isTrue);
    });

    test('idempotent — repeating the same value is still success', () {
      final gateway = AdminViewAsUserGateway();
      addTearDown(gateway.dispose);
      final useCase = SetAdminViewAsUserUseCase(gateway: gateway);

      useCase.execute(true);
      final result = useCase.execute(true);

      expect(result.isSuccess, isTrue);
      expect(gateway.currentValue, isTrue);
    });
  });
}
