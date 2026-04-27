import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/list_sizes_for_template_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart' as domain;
import 'package:oxo_menus/shared/domain/entities/status.dart';

import '../../../../../fakes/fake_size_repository.dart';
import '../../auth_helpers.dart';

const _sizes = <domain.Size>[
  domain.Size(
    id: 1,
    name: 'A4',
    width: 210,
    height: 297,
    status: Status.published,
    direction: 'portrait',
  ),
];

void main() {
  group('ListSizesForTemplateUseCase — admin', () {
    test('returns sizes from the repository', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository()..whenGetAll(const Success(_sizes));
      final useCase = ListSizesForTemplateUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.valueOrNull, _sizes);
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository()
        ..whenGetAll(const Failure(NetworkError()));
      final useCase = ListSizesForTemplateUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.errorOrNull, isA<NetworkError>());
    });
  });

  group('ListSizesForTemplateUseCase — non-admin', () {
    test('regular user is denied', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository();
      final useCase = ListSizesForTemplateUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeSizeRepository();
      final useCase = ListSizesForTemplateUseCase(
        authGateway: gateway,
        sizeRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
