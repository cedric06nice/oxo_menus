import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/list_areas_for_template_use_case.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';

import '../../../../../fakes/fake_area_repository.dart';
import '../../auth_helpers.dart';

const _areas = [Area(id: 1, name: 'Restaurant'), Area(id: 2, name: 'Bar')];

void main() {
  group('ListAreasForTemplateUseCase — admin', () {
    test('returns areas from the repository', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeAreaRepository()..whenGetAll(const Success(_areas));
      final useCase = ListAreasForTemplateUseCase(
        authGateway: gateway,
        areaRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.valueOrNull, _areas);
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final repo = FakeAreaRepository()
        ..whenGetAll(const Failure(NetworkError()));
      final useCase = ListAreasForTemplateUseCase(
        authGateway: gateway,
        areaRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.errorOrNull, isA<NetworkError>());
    });
  });

  group('ListAreasForTemplateUseCase — non-admin', () {
    test('regular user is denied', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeAreaRepository();
      final useCase = ListAreasForTemplateUseCase(
        authGateway: gateway,
        areaRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeAreaRepository();
      final useCase = ListAreasForTemplateUseCase(
        authGateway: gateway,
        areaRepository: repo,
      );

      final result = await useCase.execute(NoInput.instance);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
