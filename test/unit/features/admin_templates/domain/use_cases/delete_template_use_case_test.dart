import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/delete_template_use_case.dart';

import '../../../../../fakes/fake_menu_repository.dart';

void main() {
  group('DeleteTemplateUseCase', () {
    test('forwards the id to the repository on success', () async {
      final repo = FakeMenuRepository()..whenDelete(const Success(null));
      final useCase = DeleteTemplateUseCase(menuRepository: repo);

      final result = await useCase.execute(42);

      expect(result.isSuccess, isTrue);
      expect(repo.deleteCalls.single.id, 42);
    });

    test('passes through repository failures unchanged', () async {
      final repo = FakeMenuRepository()
        ..whenDelete(const Failure(NetworkError('offline')));
      final useCase = DeleteTemplateUseCase(menuRepository: repo);

      final result = await useCase.execute(7);

      expect(result, const Failure<void, DomainError>(NetworkError('offline')));
    });
  });
}
