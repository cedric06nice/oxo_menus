import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/load_template_for_editor_use_case.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

import '../../../../../fakes/fake_column_repository.dart';
import '../../../../../fakes/fake_container_repository.dart';
import '../../../../../fakes/fake_menu_repository.dart';
import '../../../../../fakes/fake_page_repository.dart';
import '../../../../../fakes/fake_widget_repository.dart';
import '../../auth_helpers.dart';

const _menu = Menu(id: 1, name: 'Template', version: '1', status: Status.draft);

const _contentPage = entity.Page(id: 10, menuId: 1, name: 'Page 1', index: 0);
const _headerPage = entity.Page(
  id: 11,
  menuId: 1,
  name: 'Header',
  index: 0,
  type: entity.PageType.header,
);
const _footerPage = entity.Page(
  id: 12,
  menuId: 1,
  name: 'Footer',
  index: 0,
  type: entity.PageType.footer,
);
const _container = entity.Container(id: 20, pageId: 10, index: 0);
const _column = entity.Column(id: 30, containerId: 20, index: 0);
const _widget = WidgetInstance(
  id: 40,
  columnId: 30,
  type: 'text',
  version: '1',
  index: 0,
  props: {},
);

void main() {
  group('LoadTemplateForEditorUseCase — admin', () {
    test('returns a flat tree split by header/footer/content pages', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final menuRepo = FakeMenuRepository()..whenGetById(const Success(_menu));
      final pageRepo = FakePageRepository()
        ..whenGetAllForMenu(
          const Success([_headerPage, _contentPage, _footerPage]),
        );
      final containerRepo = FakeContainerRepository()
        ..whenGetAllForPage(const Success([_container]))
        ..whenGetAllForContainer(const Success([]));
      final columnRepo = FakeColumnRepository()
        ..whenGetAllForContainer(const Success([_column]));
      final widgetRepo = FakeWidgetRepository()
        ..whenGetAllForColumn(const Success([_widget]));

      final useCase = LoadTemplateForEditorUseCase(
        authGateway: gateway,
        menuRepository: menuRepo,
        pageRepository: pageRepo,
        containerRepository: containerRepo,
        columnRepository: columnRepo,
        widgetRepository: widgetRepo,
      );

      final result = await useCase.execute(1);
      final tree = result.valueOrNull;

      expect(tree, isNotNull);
      expect(tree!.menu, _menu);
      expect(tree.pages, [_contentPage]);
      expect(tree.headerPage, _headerPage);
      expect(tree.footerPage, _footerPage);
      expect(tree.containers[10], [_container]);
      expect(tree.columns[20], [_column]);
      expect(tree.widgets[30], [_widget]);
    });

    test('surfaces menu repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final menuRepo = FakeMenuRepository()
        ..whenGetById(const Failure(NetworkError()));
      final useCase = LoadTemplateForEditorUseCase(
        authGateway: gateway,
        menuRepository: menuRepo,
        pageRepository: FakePageRepository(),
        containerRepository: FakeContainerRepository(),
        columnRepository: FakeColumnRepository(),
        widgetRepository: FakeWidgetRepository(),
      );

      final result = await useCase.execute(1);

      expect(result.errorOrNull, isA<NetworkError>());
    });

    test('surfaces page repository failures unchanged', () async {
      final gateway = await gatewayFor(adminUser);
      addTearDown(gateway.dispose);
      final menuRepo = FakeMenuRepository()..whenGetById(const Success(_menu));
      final pageRepo = FakePageRepository()
        ..whenGetAllForMenu(const Failure(NetworkError()));
      final useCase = LoadTemplateForEditorUseCase(
        authGateway: gateway,
        menuRepository: menuRepo,
        pageRepository: pageRepo,
        containerRepository: FakeContainerRepository(),
        columnRepository: FakeColumnRepository(),
        widgetRepository: FakeWidgetRepository(),
      );

      final result = await useCase.execute(1);

      expect(result.errorOrNull, isA<NetworkError>());
    });
  });

  group('LoadTemplateForEditorUseCase — non-admin', () {
    test('regular user is denied without touching the repositories', () async {
      final gateway = await gatewayFor(regularUser);
      addTearDown(gateway.dispose);
      final menuRepo = FakeMenuRepository();
      final pageRepo = FakePageRepository();
      final useCase = LoadTemplateForEditorUseCase(
        authGateway: gateway,
        menuRepository: menuRepo,
        pageRepository: pageRepo,
        containerRepository: FakeContainerRepository(),
        columnRepository: FakeColumnRepository(),
        widgetRepository: FakeWidgetRepository(),
      );

      final result = await useCase.execute(1);

      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(menuRepo.calls, isEmpty);
      expect(pageRepo.calls, isEmpty);
    });

    test('anonymous viewer is denied', () async {
      final gateway = await gatewayFor(null);
      addTearDown(gateway.dispose);
      final useCase = LoadTemplateForEditorUseCase(
        authGateway: gateway,
        menuRepository: FakeMenuRepository(),
        pageRepository: FakePageRepository(),
        containerRepository: FakeContainerRepository(),
        columnRepository: FakeColumnRepository(),
        widgetRepository: FakeWidgetRepository(),
      );

      final result = await useCase.execute(1);

      expect(result.errorOrNull, isA<UnauthorizedError>());
    });
  });
}
