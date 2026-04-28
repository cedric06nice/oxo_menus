import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/delete_menu_use_case.dart';

import '../../../../../fakes/fake_menu_repository.dart';

void main() {
  group('DeleteMenuUseCase', () {
    test('forwards the menu id to the repository', () async {
      final repo = FakeMenuRepository()..whenDelete(const Success(null));
      final useCase = DeleteMenuUseCase(menuRepository: repo);

      final result = await useCase.execute(42);

      expect(result, const Success<void, DomainError>(null));
      expect(repo.deleteCalls, hasLength(1));
      expect(repo.deleteCalls.single.id, 42);
    });

    test('surfaces repository failures unchanged', () async {
      final repo = FakeMenuRepository()
        ..whenDelete(const Failure(NetworkError()));
      final useCase = DeleteMenuUseCase(menuRepository: repo);

      final result = await useCase.execute(7);

      expect(result, const Failure<void, DomainError>(NetworkError()));
    });
  });
}
