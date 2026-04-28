import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/delete_widget_in_menu_use_case.dart';

import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

void main() {
  group('DeleteWidgetInMenuUseCase — authenticated', () {
    test('forwards id to the repository', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()..whenDelete(const Success(null));
      final useCase = DeleteWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(42);

      expect(result.isSuccess, isTrue);
      expect((repo.calls.single as WidgetDeleteCall).id, 42);
    });

    test('surfaces repository failures unchanged', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository()
        ..whenDelete(const Failure(NetworkError()));
      final useCase = DeleteWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(42);

      expect(result.errorOrNull, isA<NetworkError>());
    });
  });

  group('DeleteWidgetInMenuUseCase — anonymous', () {
    test('returns UnauthorizedError without touching the repository', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final repo = FakeWidgetRepository();
      final useCase = DeleteWidgetInMenuUseCase(
        authGateway: gateway,
        widgetRepository: repo,
      );

      final result = await useCase.execute(42);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(repo.calls, isEmpty);
    });
  });
}
