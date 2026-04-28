import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/save_menu_use_case.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

import '../../../../../fakes/fake_menu_repository.dart';
import '../../auth_helpers.dart';

const _menu = Menu(id: 1, name: 'Menu', version: '1', status: Status.draft);

void main() {
  group('SaveMenuUseCase', () {
    test('updates the menu via the repository when authenticated', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository()..whenUpdate(const Success(_menu));
      final useCase = SaveMenuUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(1);

      expect(result.valueOrNull, _menu);
      expect(repo.updateCalls.single.input.id, 1);
    });

    test('returns UnauthorizedError when anonymous', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeMenuRepository();
      final useCase = SaveMenuUseCase(
        authGateway: gateway,
        menuRepository: repo,
      );

      final result = await useCase.execute(1);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.updateCalls, isEmpty);
    });
  });
}
