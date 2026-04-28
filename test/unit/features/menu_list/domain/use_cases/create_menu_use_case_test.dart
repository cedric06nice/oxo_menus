import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/create_menu_use_case.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

import '../../../../../fakes/fake_menu_repository.dart';

const _menu = Menu(
  id: 1,
  name: 'Spring Menu',
  status: Status.draft,
  version: '1.0.0',
);

const _input = CreateMenuInput(
  name: 'Spring Menu',
  version: '1.0.0',
  status: Status.draft,
  sizeId: 5,
);

void main() {
  group('CreateMenuUseCase', () {
    test('forwards the input to the repository and returns its menu', () async {
      final repo = FakeMenuRepository()..whenCreate(const Success(_menu));
      final useCase = CreateMenuUseCase(menuRepository: repo);

      final result = await useCase.execute(_input);

      expect(result, const Success<Menu, DomainError>(_menu));
      expect(repo.createCalls, hasLength(1));
      expect(repo.createCalls.single.input, _input);
    });

    test('surfaces repository failures unchanged', () async {
      final repo = FakeMenuRepository()
        ..whenCreate(const Failure(ServerError()));
      final useCase = CreateMenuUseCase(menuRepository: repo);

      final result = await useCase.execute(_input);

      expect(result, const Failure<Menu, DomainError>(ServerError()));
    });
  });
}
