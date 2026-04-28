import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oxo_menus/core/di/app_scope.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/gateways/connectivity_gateway.dart';
import 'package:oxo_menus/core/routing/app_router.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/core/gateways/app_version_gateway.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:oxo_menus/features/auth/presentation/screens/login_screen.dart';
import 'package:oxo_menus/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:oxo_menus/features/connectivity/domain/entities/connectivity_status.dart';
import 'package:oxo_menus/features/home/presentation/screens/home_screen.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_page_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/create_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_page_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/delete_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/duplicate_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/list_areas_for_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/list_sizes_for_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/load_template_for_editor_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/move_widget_in_template_use_case.dart'
    as admin_template_move;
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/reorder_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_column_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_container_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_template_menu_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/domain/use_cases/update_widget_in_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/routing/admin_template_editor_route_adapter.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/screens/admin_template_editor_screen.dart';
import 'package:oxo_menus/features/admin_template_editor/presentation/view_models/admin_template_editor_view_model.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_presence.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart'
    as col_entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as container_entity;
import 'package:oxo_menus/features/menu/domain/entities/editor_tree_data.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart'
    as page_entity;
import 'package:oxo_menus/features/menu/domain/entities/size.dart'
    as size_entity;
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/create_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/delete_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/load_menu_for_editor_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/lock_widget_for_editing_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/menu_presence_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/move_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/publish_exportable_bundles_for_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/save_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/unlock_widget_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/update_widget_in_menu_use_case.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/watch_menu_changes_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/menu_editor_route_adapter.dart';
import 'package:oxo_menus/features/menu_editor/presentation/screens/menu_editor_screen.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/menu_editor_view_model.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/create_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/delete_menu_use_case.dart';
import 'package:oxo_menus/features/menu_list/domain/use_cases/list_menus_for_viewer_use_case.dart';
import 'package:oxo_menus/features/menu_list/presentation/routing/menu_list_route_adapter.dart';
import 'package:oxo_menus/features/menu_list/presentation/screens/menu_list_screen.dart';
import 'package:oxo_menus/features/menu_list/presentation/view_models/menu_list_view_model.dart';
import 'package:oxo_menus/features/settings/presentation/screens/settings_screen.dart';
import 'package:oxo_menus/features/menu/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/generate_menu_pdf_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_route_adapter.dart';
import 'package:oxo_menus/features/menu_editor/presentation/screens/pdf_preview_screen.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/pdf_preview_view_model.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/create_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/delete_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/list_sizes_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/domain/use_cases/update_size_use_case.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/routing/admin_sizes_route_adapter.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/screens/admin_sizes_screen.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/view_models/admin_sizes_view_model.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/create_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/delete_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/list_available_menus_for_bundles_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/list_menu_bundles_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/publish_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/domain/use_cases/update_menu_bundle_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/routing/admin_exportable_menus_route_adapter.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/screens/admin_exportable_menus_screen.dart';
import 'package:oxo_menus/features/admin_exportable_menus/presentation/view_models/admin_exportable_menus_view_model.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/create_template_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_areas_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/domain/use_cases/list_sizes_for_creator_use_case.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/routing/admin_template_creator_route_adapter.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/screens/admin_template_creator_screen.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/view_models/admin_template_creator_view_model.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/delete_template_use_case.dart';
import 'package:oxo_menus/features/admin_templates/domain/use_cases/list_templates_for_admin_use_case.dart';
import 'package:oxo_menus/features/admin_templates/presentation/routing/admin_templates_route_adapter.dart';
import 'package:oxo_menus/features/admin_templates/presentation/screens/admin_templates_screen.dart';
import 'package:oxo_menus/features/admin_templates/presentation/view_models/admin_templates_view_model.dart';
import 'package:oxo_menus/features/menu/domain/repositories/column_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/container_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/page_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/features/menu/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';

import '../../../fakes/fake_auth_repository.dart';
import '../../../fakes/fake_connectivity_repository.dart';
import '../../../fakes/fake_menu_repository.dart';
import '../../../fakes/builders/user_builder.dart';
import '../../../fakes/reflectable_bootstrap.dart';

// ---------------------------------------------------------------------------
// Local test-only DuplicateMenuUseCase fake
// ---------------------------------------------------------------------------

/// Extends [DuplicateMenuUseCase] and satisfies all required repository
/// constructor args with no-op stubs so tests can override execute() behaviour.
class _FakeDuplicateMenuUseCase extends DuplicateMenuUseCase {
  _FakeDuplicateMenuUseCase()
    : super(
        fetchMenuTreeUseCase: _ThrowFetchMenuTreeUseCase(),
        menuRepository: _ThrowMenuRepository(),
        pageRepository: _ThrowPageRepository(),
        containerRepository: _ThrowContainerRepository(),
        columnRepository: _ThrowColumnRepository(),
        widgetRepository: _ThrowWidgetRepository(),
        sizeRepository: _ThrowSizeRepository(),
      );
}

// Minimal throw-only stubs used solely to satisfy DuplicateMenuUseCase constructor

class _ThrowFetchMenuTreeUseCase extends FetchMenuTreeUseCase {
  _ThrowFetchMenuTreeUseCase()
    : super(
        menuRepository: _ThrowMenuRepository(),
        pageRepository: _ThrowPageRepository(),
        containerRepository: _ThrowContainerRepository(),
        columnRepository: _ThrowColumnRepository(),
        widgetRepository: _ThrowWidgetRepository(),
      );

  @override
  Future<Result<MenuTree, DomainError>> execute(int menuId) async {
    throw StateError('_ThrowFetchMenuTreeUseCase.execute should not be called');
  }
}

class _ThrowMenuRepository implements MenuRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowMenuRepository.${i.memberName} called unexpectedly',
  );
}

class _ThrowPageRepository implements PageRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowPageRepository.${i.memberName} called unexpectedly',
  );
}

class _ThrowContainerRepository implements ContainerRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowContainerRepository.${i.memberName} called unexpectedly',
  );
}

class _ThrowColumnRepository implements ColumnRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowColumnRepository.${i.memberName} called unexpectedly',
  );
}

class _ThrowWidgetRepository implements WidgetRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowWidgetRepository.${i.memberName} called unexpectedly',
  );
}

class _ThrowSizeRepository implements SizeRepository {
  @override
  dynamic noSuchMethod(Invocation i) => throw StateError(
    '_ThrowSizeRepository.${i.memberName} called unexpectedly',
  );
}

/// Static [AppVersionGateway] used by router tests that mount the MVVM
/// Settings screen — avoids invoking the real `package_info_plus` plugin which
/// is not available in the unit-test sandbox.
class _FakeAppVersionGateway implements AppVersionGateway {
  @override
  Future<String> read() async => '1.0.0';
}

/// No-op [ListMenusForViewerUseCase] used by [_buildMenuListVm] so the
/// `/menus` host can stand up a [MenuListViewModel] without touching a
/// real `DirectusDataSource`.
class _StubListMenusForViewerUseCase implements ListMenusForViewerUseCase {
  @override
  Future<Result<List<Menu>, DomainError>> execute(NoInput input) async =>
      const Success(<Menu>[]);
}

class _StubCreateMenuUseCase implements CreateMenuUseCase {
  @override
  Future<Result<Menu, DomainError>> execute(CreateMenuInput input) async =>
      const Failure(UnauthorizedError());
}

class _StubDeleteMenuUseCase implements DeleteMenuUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

/// Builds a [MenuListViewModel] backed entirely by stubs — used by the router
/// tests so the Phase 18 `/menus` host can mount [MenuListScreen]
/// without spinning up a real `DirectusDataSource`. Mirrors the existing
/// [`_FakeDuplicateMenuUseCase`] pattern above.
MenuListViewModel _buildMenuListVm(
  BuildContext context,
  AppContainer container,
) {
  return MenuListViewModel(
    listMenusForViewer: _StubListMenusForViewerUseCase(),
    createMenu: _StubCreateMenuUseCase(),
    deleteMenu: _StubDeleteMenuUseCase(),
    duplicateMenu: _FakeDuplicateMenuUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: MenuListRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

/// No-op [ListTemplatesForAdminUseCase] used by [_buildAdminTemplatesVm]
/// so the `/admin/templates` host can stand up an
/// [AdminTemplatesViewModel] without touching a real `DirectusDataSource`.
class _StubListTemplatesForAdminUseCase
    implements ListTemplatesForAdminUseCase {
  @override
  Future<Result<List<Menu>, DomainError>> execute(
    ListTemplatesForAdminInput input,
  ) async => const Success(<Menu>[]);
}

class _StubDeleteTemplateUseCase implements DeleteTemplateUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

/// Builds an [AdminTemplatesViewModel] backed entirely by stubs — used by the
/// router tests so the Phase 19 `/admin/templates` host can mount
/// [AdminTemplatesScreen] without spinning up a real `DirectusDataSource`.
AdminTemplatesViewModel _buildAdminTemplatesVm(
  BuildContext context,
  AppContainer container,
) {
  return AdminTemplatesViewModel(
    listTemplates: _StubListTemplatesForAdminUseCase(),
    deleteTemplate: _StubDeleteTemplateUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: AdminTemplatesRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

/// Empty-list [ListSizesForAdminUseCase] used by [_buildAdminSizesVm] so
/// the `/admin/sizes` host can stand up an [AdminSizesViewModel]
/// without touching a real `DirectusDataSource`.
class _StubListSizesForAdminUseCase implements ListSizesForAdminUseCase {
  @override
  Future<Result<List<size_entity.Size>, DomainError>> execute(
    ListSizesForAdminInput input,
  ) async => const Success(<size_entity.Size>[]);
}

class _StubCreateSizeUseCase implements CreateSizeUseCase {
  @override
  Future<Result<size_entity.Size, DomainError>> execute(
    CreateSizeInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubUpdateSizeUseCase implements UpdateSizeUseCase {
  @override
  Future<Result<size_entity.Size, DomainError>> execute(
    UpdateSizeInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubDeleteSizeUseCase implements DeleteSizeUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

/// Builds an [AdminSizesViewModel] backed entirely by stubs — used by the
/// router tests so the Phase 20 `/admin/sizes` host can mount
/// [AdminSizesScreen] without spinning up a real `DirectusDataSource`.
AdminSizesViewModel _buildAdminSizesVm(
  BuildContext context,
  AppContainer container,
) {
  return AdminSizesViewModel(
    listSizes: _StubListSizesForAdminUseCase(),
    createSize: _StubCreateSizeUseCase(),
    updateSize: _StubUpdateSizeUseCase(),
    deleteSize: _StubDeleteSizeUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: AdminSizesRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

/// Empty-list [ListSizesForCreatorUseCase] used by
/// [_buildAdminTemplateCreatorVm] so the `/admin/templates/create` host can
/// stand up an [AdminTemplateCreatorViewModel] without touching a real
/// `DirectusDataSource`.
class _StubListSizesForCreatorUseCase implements ListSizesForCreatorUseCase {
  @override
  Future<Result<List<size_entity.Size>, DomainError>> execute(
    NoInput input,
  ) async => const Success(<size_entity.Size>[]);
}

class _StubListAreasForCreatorUseCase implements ListAreasForCreatorUseCase {
  @override
  Future<Result<List<Area>, DomainError>> execute(NoInput input) async =>
      const Success(<Area>[]);
}

class _StubCreateTemplateUseCase implements CreateTemplateUseCase {
  @override
  Future<Result<Menu, DomainError>> execute(CreateTemplateInput input) async =>
      const Failure(UnauthorizedError());
}

/// Builds an [AdminTemplateCreatorViewModel] backed entirely by stubs — used
/// by the router tests so the Phase 21 `/admin/templates/create` host
/// can mount [AdminTemplateCreatorScreen] without spinning up a real
/// `DirectusDataSource`.
AdminTemplateCreatorViewModel _buildAdminTemplateCreatorVm(
  BuildContext context,
  AppContainer container,
) {
  return AdminTemplateCreatorViewModel(
    listSizes: _StubListSizesForCreatorUseCase(),
    listAreas: _StubListAreasForCreatorUseCase(),
    createTemplate: _StubCreateTemplateUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: AdminTemplateCreatorRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

/// [GenerateMenuPdfUseCase] that always fails. Used by the Phase 22 router
/// test so the `/menus/pdf/:id` host can mount [PdfPreviewScreen]
/// without spinning up a real `DirectusDataSource` — the screen settles into
/// its error state immediately, which is enough for the cutover assertion.
class _StubGenerateMenuPdfUseCase implements GenerateMenuPdfUseCase {
  @override
  Future<Result<GenerateMenuPdfOutput, DomainError>> execute(
    GenerateMenuPdfInput input,
  ) async => const Failure(NetworkError('stub'));
}

/// Builds a [PdfPreviewViewModel] backed entirely by stubs — used by the
/// router tests so the Phase 22 `/menus/pdf/:id` host can mount
/// [PdfPreviewScreen] without spinning up a real `DirectusDataSource`.
PdfPreviewViewModel _buildPdfPreviewVm(
  BuildContext context,
  AppContainer container,
  int menuId,
) {
  return PdfPreviewViewModel(
    menuId: menuId,
    generatePdf: _StubGenerateMenuPdfUseCase(),
    router: PdfPreviewRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

/// Empty-list / no-op use cases used by [_buildAdminExportableMenusVm]
/// so the `/admin/exportable_menus` host can stand up an
/// [AdminExportableMenusViewModel] without touching a real
/// `DirectusDataSource`. Each stub returns a [Failure] or an empty [Success]
/// — enough for the cutover assertion that the screen mounts.
class _StubListMenuBundlesForAdminUseCase
    implements ListMenuBundlesForAdminUseCase {
  @override
  Future<Result<List<MenuBundle>, DomainError>> execute(NoInput input) async =>
      const Success(<MenuBundle>[]);
}

class _StubListAvailableMenusForBundlesUseCase
    implements ListAvailableMenusForBundlesUseCase {
  @override
  Future<Result<List<Menu>, DomainError>> execute(NoInput input) async =>
      const Success(<Menu>[]);
}

class _StubCreateMenuBundleForAdminUseCase
    implements CreateMenuBundleForAdminUseCase {
  @override
  Future<Result<MenuBundle, DomainError>> execute(
    CreateMenuBundleInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubUpdateMenuBundleForAdminUseCase
    implements UpdateMenuBundleForAdminUseCase {
  @override
  Future<Result<MenuBundle, DomainError>> execute(
    UpdateMenuBundleInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubDeleteMenuBundleForAdminUseCase
    implements DeleteMenuBundleForAdminUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

class _StubPublishMenuBundleForAdminUseCase
    implements PublishMenuBundleForAdminUseCase {
  @override
  Future<Result<MenuBundle, DomainError>> execute(int input) async =>
      const Failure(UnauthorizedError());
}

// ---------------------------------------------------------------------------
// Phase 24 — stubs for /menus/:id and /admin/templates/:id hosts
// ---------------------------------------------------------------------------
//
// MenuEditorViewModel and AdminTemplateEditorViewModel each take a long list
// of use cases as constructor arguments. The cutover assertion is just "the
// MVVM screen mounts at the canonical path" — the screen settles into its error
// or empty state immediately, which is enough. Each stub `implements` the
// concrete use case and returns Failure / empty Success / empty Stream so no
// repository, websocket, or timer is touched.

class _StubLoadMenuForEditorUseCase implements LoadMenuForEditorUseCase {
  @override
  Future<Result<EditorTreeData, DomainError>> execute(int input) async =>
      const Failure(NetworkError('stub'));
}

class _StubCreateWidgetInMenuUseCase implements CreateWidgetInMenuUseCase {
  @override
  Future<Result<WidgetInstance, DomainError>> execute(
    CreateWidgetInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubUpdateWidgetInMenuUseCase implements UpdateWidgetInMenuUseCase {
  @override
  Future<Result<WidgetInstance, DomainError>> execute(
    UpdateWidgetInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubDeleteWidgetInMenuUseCase implements DeleteWidgetInMenuUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

class _StubMoveWidgetInMenuUseCase implements MoveWidgetInMenuUseCase {
  @override
  Future<Result<void, DomainError>> execute(MoveWidgetInput input) async =>
      const Failure(UnauthorizedError());
}

class _StubLockWidgetForEditingUseCase implements LockWidgetForEditingUseCase {
  @override
  Future<Result<void, DomainError>> execute(
    LockWidgetForEditingInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubUnlockWidgetUseCase implements UnlockWidgetUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

class _StubSaveMenuUseCase implements SaveMenuUseCase {
  @override
  Future<Result<Menu, DomainError>> execute(int input) async =>
      const Failure(UnauthorizedError());
}

class _StubPublishExportableBundlesForMenuUseCase
    implements PublishExportableBundlesForMenuUseCase {
  @override
  Future<List<Result<MenuBundle, DomainError>>> execute(int menuId) async =>
      const <Result<MenuBundle, DomainError>>[];
}

class _StubWatchMenuChangesUseCase implements WatchMenuChangesUseCase {
  @override
  Stream<MenuChangeEvent> execute(int menuId) =>
      const Stream<MenuChangeEvent>.empty();

  @override
  Future<void> cancel(int menuId) async {}
}

class _StubMenuPresenceUseCase implements MenuPresenceUseCase {
  @override
  Future<Result<void, DomainError>> join(
    int menuId,
    String userId, {
    String? userName,
    String? userAvatar,
  }) async => const Success(null);

  @override
  Future<Result<void, DomainError>> leave(int menuId, String userId) async =>
      const Success(null);

  @override
  Future<Result<void, DomainError>> heartbeat(
    int menuId,
    String userId,
  ) async => const Success(null);

  @override
  Future<Result<List<MenuPresence>, DomainError>> getActive(int menuId) async =>
      const Success(<MenuPresence>[]);

  @override
  Stream<List<MenuPresence>> watch(int menuId) =>
      const Stream<List<MenuPresence>>.empty();

  @override
  Future<void> cancel(int menuId) async {}
}

/// Builds a [MenuEditorViewModel] backed entirely by stubs — used by the
/// router tests so the Phase 24 `/menus/:id` host can mount
/// [MenuEditorScreen] without spinning up a real `DirectusDataSource`.
MenuEditorViewModel _buildMenuEditorVm(
  BuildContext context,
  AppContainer container,
  int menuId,
) {
  return MenuEditorViewModel(
    menuId: menuId,
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: MenuEditorRouteAdapter(GoRouterRouteNavigator(context)),
    registry: PresentableWidgetRegistry(),
    loadMenu: _StubLoadMenuForEditorUseCase(),
    createWidget: _StubCreateWidgetInMenuUseCase(),
    updateWidget: _StubUpdateWidgetInMenuUseCase(),
    deleteWidget: _StubDeleteWidgetInMenuUseCase(),
    moveWidget: _StubMoveWidgetInMenuUseCase(),
    lockWidget: _StubLockWidgetForEditingUseCase(),
    unlockWidget: _StubUnlockWidgetUseCase(),
    saveMenu: _StubSaveMenuUseCase(),
    publishBundles: _StubPublishExportableBundlesForMenuUseCase(),
    watchChanges: _StubWatchMenuChangesUseCase(),
    presence: _StubMenuPresenceUseCase(),
  );
}

class _StubLoadTemplateForEditorUseCase
    implements LoadTemplateForEditorUseCase {
  @override
  Future<Result<EditorTreeData, DomainError>> execute(int input) async =>
      const Failure(NetworkError('stub'));
}

class _StubCreatePageInTemplateUseCase implements CreatePageInTemplateUseCase {
  @override
  Future<Result<page_entity.Page, DomainError>> execute(
    CreatePageInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubDeletePageInTemplateUseCase implements DeletePageInTemplateUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

class _StubCreateContainerInTemplateUseCase
    implements CreateContainerInTemplateUseCase {
  @override
  Future<Result<container_entity.Container, DomainError>> execute(
    CreateContainerInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubUpdateContainerInTemplateUseCase
    implements UpdateContainerInTemplateUseCase {
  @override
  Future<Result<container_entity.Container, DomainError>> execute(
    UpdateContainerInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubDeleteContainerInTemplateUseCase
    implements DeleteContainerInTemplateUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

class _StubReorderContainerInTemplateUseCase
    implements ReorderContainerInTemplateUseCase {
  @override
  Future<Result<void, DomainError>> execute(
    ReorderContainerInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubDuplicateContainerInTemplateUseCase
    implements DuplicateContainerInTemplateUseCase {
  @override
  Future<Result<container_entity.Container, DomainError>> execute(
    int input,
  ) async => const Failure(UnauthorizedError());
}

class _StubCreateColumnInTemplateUseCase
    implements CreateColumnInTemplateUseCase {
  @override
  Future<Result<col_entity.Column, DomainError>> execute(
    CreateColumnInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubUpdateColumnInTemplateUseCase
    implements UpdateColumnInTemplateUseCase {
  @override
  Future<Result<col_entity.Column, DomainError>> execute(
    UpdateColumnInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubDeleteColumnInTemplateUseCase
    implements DeleteColumnInTemplateUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

class _StubCreateWidgetInTemplateUseCase
    implements CreateWidgetInTemplateUseCase {
  @override
  Future<Result<WidgetInstance, DomainError>> execute(
    CreateWidgetInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubUpdateWidgetInTemplateUseCase
    implements UpdateWidgetInTemplateUseCase {
  @override
  Future<Result<WidgetInstance, DomainError>> execute(
    UpdateWidgetInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubDeleteWidgetInTemplateUseCase
    implements DeleteWidgetInTemplateUseCase {
  @override
  Future<Result<void, DomainError>> execute(int input) async =>
      const Success(null);
}

class _StubMoveWidgetInTemplateUseCase
    implements admin_template_move.MoveWidgetInTemplateUseCase {
  @override
  Future<Result<void, DomainError>> execute(
    admin_template_move.MoveWidgetInput input,
  ) async => const Failure(UnauthorizedError());
}

class _StubUpdateTemplateMenuUseCase implements UpdateTemplateMenuUseCase {
  @override
  Future<Result<Menu, DomainError>> execute(UpdateMenuInput input) async =>
      const Failure(UnauthorizedError());
}

class _StubListAreasForTemplateUseCase implements ListAreasForTemplateUseCase {
  @override
  Future<Result<List<Area>, DomainError>> execute(NoInput input) async =>
      const Success(<Area>[]);
}

class _StubListSizesForTemplateUseCase implements ListSizesForTemplateUseCase {
  @override
  Future<Result<List<size_entity.Size>, DomainError>> execute(
    NoInput input,
  ) async => const Success(<size_entity.Size>[]);
}

/// Builds an [AdminTemplateEditorViewModel] backed entirely by stubs — used by
/// the router tests so the Phase 24 `/admin/templates/:id` host can
/// mount [AdminTemplateEditorScreen] without spinning up a real
/// `DirectusDataSource`.
AdminTemplateEditorViewModel _buildAdminTemplateEditorVm(
  BuildContext context,
  AppContainer container,
  int menuId,
) {
  return AdminTemplateEditorViewModel(
    menuId: menuId,
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: AdminTemplateEditorRouteAdapter(GoRouterRouteNavigator(context)),
    registry: PresentableWidgetRegistry(),
    loadTemplate: _StubLoadTemplateForEditorUseCase(),
    createPage: _StubCreatePageInTemplateUseCase(),
    deletePage: _StubDeletePageInTemplateUseCase(),
    createContainer: _StubCreateContainerInTemplateUseCase(),
    updateContainer: _StubUpdateContainerInTemplateUseCase(),
    deleteContainer: _StubDeleteContainerInTemplateUseCase(),
    reorderContainer: _StubReorderContainerInTemplateUseCase(),
    duplicateContainer: _StubDuplicateContainerInTemplateUseCase(),
    createColumn: _StubCreateColumnInTemplateUseCase(),
    updateColumn: _StubUpdateColumnInTemplateUseCase(),
    deleteColumn: _StubDeleteColumnInTemplateUseCase(),
    createWidget: _StubCreateWidgetInTemplateUseCase(),
    updateWidget: _StubUpdateWidgetInTemplateUseCase(),
    deleteWidget: _StubDeleteWidgetInTemplateUseCase(),
    moveWidget: _StubMoveWidgetInTemplateUseCase(),
    updateMenu: _StubUpdateTemplateMenuUseCase(),
    listAreas: _StubListAreasForTemplateUseCase(),
    listSizes: _StubListSizesForTemplateUseCase(),
  );
}

/// Builds an [AdminExportableMenusViewModel] backed entirely by stubs — used
/// by the router tests so the Phase 23 `/admin/exportable_menus` host
/// can mount [AdminExportableMenusScreen] without spinning up a real
/// `DirectusDataSource`.
AdminExportableMenusViewModel _buildAdminExportableMenusVm(
  BuildContext context,
  AppContainer container,
) {
  return AdminExportableMenusViewModel(
    listBundles: _StubListMenuBundlesForAdminUseCase(),
    listAvailableMenus: _StubListAvailableMenusForBundlesUseCase(),
    createBundle: _StubCreateMenuBundleForAdminUseCase(),
    updateBundle: _StubUpdateMenuBundleForAdminUseCase(),
    deleteBundle: _StubDeleteMenuBundleForAdminUseCase(),
    publishBundle: _StubPublishMenuBundleForAdminUseCase(),
    authGateway: container.authGateway,
    connectivityGateway: container.connectivityGateway,
    router: AdminExportableMenusRouteAdapter(GoRouterRouteNavigator(context)),
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds the minimal widget tree required for the router to function
/// without hitting real infrastructure. Wraps [MaterialApp.router] in an
/// [AppScope] backed by the supplied fakes; the [AppRouter] is constructed
/// with stub view-model builders so screens can mount without a live
/// `DirectusDataSource`.
///
/// [fakeAuth] — pre-configured with a [defaultTryRestoreSessionResponse].
/// [fakeMenu] — pre-configured with a listAll and getById response.
Widget _buildApp({
  required FakeAuthRepository fakeAuth,
  required FakeMenuRepository fakeMenu,
  void Function(GoRouter)? onRouter,
  AppVersionGateway? appVersionGateway,
}) {
  // Wire fakeMenu through the menu-list / templates use cases via stub
  // implementations: those tests interact with the screens, not the menu
  // repo directly. The auth gateway is shared so the auth redirect and the
  // login screen see the same state machine.
  final authGateway = AuthGateway(repository: fakeAuth);
  final connectivityGateway = ConnectivityGateway(
    repository: FakeConnectivityRepository()
      ..whenCheckConnectivity(ConnectivityStatus.online),
  );
  final container = AppContainer(
    authGateway: authGateway,
    connectivityGateway: connectivityGateway,
    appVersionGateway: appVersionGateway,
  );

  return AppScope(
    container: container,
    child: _RouterTestHarness(container: container, onRouter: onRouter),
  );
}

/// Stateful host for the router tests that builds the [AppRouter] once and
/// keeps the same router instance across rebuilds — mirroring how
/// `MyApp` wires the router in production.
class _RouterTestHarness extends StatefulWidget {
  const _RouterTestHarness({required this.container, this.onRouter});

  final AppContainer container;
  final void Function(GoRouter)? onRouter;

  @override
  State<_RouterTestHarness> createState() => _RouterTestHarnessState();
}

class _RouterTestHarnessState extends State<_RouterTestHarness> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_router == null) {
      final scope = AppScope.of(context);
      final router = AppRouter(
        scope: scope,
        menuListBuilder: _buildMenuListVm,
        adminTemplatesBuilder: _buildAdminTemplatesVm,
        adminSizesBuilder: _buildAdminSizesVm,
        adminTemplateCreatorBuilder: _buildAdminTemplateCreatorVm,
        pdfPreviewBuilder: _buildPdfPreviewVm,
        adminExportableMenusBuilder: _buildAdminExportableMenusVm,
        menuEditorBuilder: _buildMenuEditorVm,
        adminTemplateEditorBuilder: _buildAdminTemplateEditorVm,
      ).build();
      widget.onRouter?.call(router);
      _router = router;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router!);
  }
}

/// Configures [FakeMenuRepository] with the empty-list defaults that
/// nearly every router test needs so pages don't throw on load.
void _configureMenuRepository(FakeMenuRepository repo) {
  repo.whenListAll(const Success([]));
  repo.whenGetById(const Failure(NotFoundError()));
}

void main() {
  setUpAll(initializeReflectableForTests);

  group('AppRouter — auth guards', () {
    testWidgets(
      'should redirect unauthenticated user to /login when visiting splash',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = const Failure(
          UnauthorizedError(),
        );

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        await tester.pumpWidget(
          _buildApp(fakeAuth: fakeAuth, fakeMenu: fakeMenu),
        );
        await tester.pumpAndSettle();

        expect(find.text('OXO Menus'), findsOneWidget);
      },
    );

    testWidgets(
      'should redirect authenticated user to /home when visiting splash',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        await tester.pumpWidget(
          _buildApp(fakeAuth: fakeAuth, fakeMenu: fakeMenu),
        );
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);
      },
    );

    testWidgets(
      'should redirect unauthenticated user to /login when navigating to /menus',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = const Failure(
          UnauthorizedError(),
        );

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/menus');
        await tester.pumpAndSettle();

        expect(find.text('OXO Menus'), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsOneWidget);
      },
    );

    testWidgets(
      'should redirect authenticated user away from /login to /home',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/login');
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);
      },
    );
  });

  group('AppRouter — admin guards', () {
    testWidgets(
      'should block non-admin user from /admin/templates and redirect to /home',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/admin/templates');
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);
        expect(find.text('No templates found'), findsNothing);
      },
    );

    testWidgets('should allow admin user to access /admin/templates', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildAdminUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/admin/templates');
      await tester.pumpAndSettle();

      expect(find.text('No templates found'), findsOneWidget);
    });

    testWidgets(
      'should block non-admin user from /admin/sizes and redirect to /home',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/admin/sizes');
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);
      },
    );

    testWidgets(
      'should block non-admin user from /admin/exportable_menus and redirect to /home',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/admin/exportable_menus');
        await tester.pumpAndSettle();

        expect(find.text('Quick Actions'), findsOneWidget);
      },
    );
  });

  group('AppRouter — public routes accessible when unauthenticated', () {
    testWidgets(
      'should allow unauthenticated user to access /forgot-password',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = const Failure(
          UnauthorizedError(),
        );

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/forgot-password');
        await tester.pumpAndSettle();

        expect(find.text('Forgot Password'), findsOneWidget);
      },
    );

    testWidgets('should allow unauthenticated user to access /reset-password', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = const Failure(
        UnauthorizedError(),
      );

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/reset-password?token=abc123');
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsAtLeast(1));
      expect(find.byKey(const Key('login_button')), findsNothing);
    });
  });

  // Phase 15 — the /login, /forgot-password, /reset-password GoRoutes
  // now host the MVVM screens directly (LoginScreen, ForgotPasswordScreen,
  // ResetPasswordScreen) instead of the retired *_page.dart widgets. These
  // tests pin the cutover so the screens cannot silently regress.
  group('AppRouter — auth paths host MVVM screens', () {
    testWidgets('/login mounts LoginScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = const Failure(
        UnauthorizedError(),
      );

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/login');
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('/forgot-password mounts ForgotPasswordScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = const Failure(
        UnauthorizedError(),
      );

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/forgot-password');
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets(
      '/reset-password?token=… mounts ResetPasswordScreen with a usable token',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = const Failure(
          UnauthorizedError(),
        );

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/reset-password?token=abc123');
        await tester.pumpAndSettle();

        expect(find.byType(ResetPasswordScreen), findsOneWidget);
        // Token is captured — the screen renders the form, not the
        // missing-token branch.
        expect(find.byKey(const Key('reset_password_button')), findsOneWidget);
        expect(find.text('Invalid or missing reset token'), findsNothing);
      },
    );

    testWidgets('/reset-password without a token mounts ResetPasswordScreen in '
        'missing-token branch', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = const Failure(
        UnauthorizedError(),
      );

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/reset-password');
      await tester.pumpAndSettle();

      expect(find.byType(ResetPasswordScreen), findsOneWidget);
      expect(find.text('Invalid or missing reset token'), findsOneWidget);
    });
  });

  // Phase 17 — the /home GoRoute now hosts the MVVM HomeScreen
  // directly instead of the retired HomePage widget. This test pins the
  // cutover so the screen cannot silently regress.
  group('AppRouter — /home hosts MVVM screen', () {
    testWidgets('/home mounts HomeScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/home');
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  // Phase 18 — the /menus GoRoute now hosts the MVVM MenuListScreen
  // directly instead of the retired MenuListPage widget. This test pins the
  // cutover so the screen cannot silently regress.
  group('AppRouter — /menus hosts MVVM screen', () {
    testWidgets('/menus mounts MenuListScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/menus');
      await tester.pumpAndSettle();

      expect(find.byType(MenuListScreen), findsOneWidget);
    });
  });

  // Phase 19 — the /admin/templates GoRoute now hosts the MVVM
  // AdminTemplatesScreen directly instead of the retired AdminTemplatesPage
  // widget. This test pins the cutover so the screen cannot silently regress.
  group('AppRouter — /admin/templates hosts MVVM screen', () {
    testWidgets('/admin/templates mounts AdminTemplatesScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildAdminUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/admin/templates');
      await tester.pumpAndSettle();

      expect(find.byType(AdminTemplatesScreen), findsOneWidget);
    });
  });

  // Phase 20 — the /admin/sizes GoRoute now hosts the MVVM
  // AdminSizesScreen directly instead of the retired AdminSizesPage widget.
  // This test pins the cutover so the screen cannot silently regress.
  group('AppRouter — /admin/sizes hosts MVVM screen', () {
    testWidgets('/admin/sizes mounts AdminSizesScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildAdminUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/admin/sizes');
      await tester.pumpAndSettle();

      expect(find.byType(AdminSizesScreen), findsOneWidget);
    });
  });

  // Phase 16 — the /settings GoRoute now hosts the MVVM SettingsScreen
  // directly instead of the retired SettingsPage widget. This test pins the
  // cutover so the screen cannot silently regress.
  group('AppRouter — /settings hosts MVVM screen', () {
    testWidgets('/settings mounts SettingsScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          appVersionGateway: _FakeAppVersionGateway(),
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/settings');
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('AppRouter — authenticated routes reachable', () {
    testWidgets('should render /menus page for authenticated user', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/menus');
      await tester.pumpAndSettle();

      expect(find.text('Menus'), findsAtLeast(1));
    });

    testWidgets('should render /settings page for authenticated user', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/settings');
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsAtLeast(1));
    });

    // Phase 24 — restored at /menus/:id with the MVVM screen. Pinned by the
    // dedicated cutover group below.
  });

  // /menus/:id hosts the MVVM MenuEditorScreen directly. Pins the cutover so
  // the screen cannot silently regress.
  group('AppRouter — /menus/:id hosts MVVM screen', () {
    testWidgets('/menus/2 mounts MenuEditorScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/menus/2');
      await tester.pumpAndSettle();

      expect(find.byType(MenuEditorScreen), findsOneWidget);
    });
  });

  // /admin/templates/:id hosts the MVVM AdminTemplateEditorScreen directly.
  // Pins the cutover so the screen cannot silently regress.
  group('AppRouter — /admin/templates/:id hosts MVVM screen', () {
    testWidgets('/admin/templates/3 mounts AdminTemplateEditorScreen', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildAdminUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/admin/templates/3');
      await tester.pumpAndSettle();

      expect(find.byType(AdminTemplateEditorScreen), findsOneWidget);
    });
  });

  // /admin/templates/create hosts the MVVM AdminTemplateCreatorScreen
  // directly. Pins the cutover so the screen cannot silently regress.
  group('AppRouter — /admin/templates/create hosts MVVM screen', () {
    testWidgets('/admin/templates/create mounts AdminTemplateCreatorScreen', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildAdminUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/admin/templates/create');
      await tester.pumpAndSettle();

      expect(find.byType(AdminTemplateCreatorScreen), findsOneWidget);
    });
  });

  // Phase 22 — the /menus/pdf/:id GoRoute now hosts the MVVM
  // PdfPreviewScreen directly instead of the retired PdfPreviewPage widget.
  // This test pins the cutover so the screen cannot silently regress.
  group('AppRouter — /menus/pdf/:id hosts MVVM screen', () {
    testWidgets('/menus/pdf/1 mounts PdfPreviewScreen', (tester) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/menus/pdf/1');
      await tester.pumpAndSettle();

      expect(find.byType(PdfPreviewScreen), findsOneWidget);
    });
  });

  // Phase 23 — the /admin/exportable_menus GoRoute now hosts the MVVM
  // AdminExportableMenusScreen directly instead of the retired
  // AdminExportableMenusPage widget. This test pins the cutover so the screen
  // cannot silently regress.
  group('AppRouter — /admin/exportable_menus hosts MVVM screen', () {
    testWidgets('/admin/exportable_menus mounts AdminExportableMenusScreen', (
      tester,
    ) async {
      final fakeAuth = FakeAuthRepository();
      fakeAuth.defaultTryRestoreSessionResponse = Success(buildAdminUser());

      final fakeMenu = FakeMenuRepository();
      _configureMenuRepository(fakeMenu);

      late GoRouter router;

      await tester.pumpWidget(
        _buildApp(
          fakeAuth: fakeAuth,
          fakeMenu: fakeMenu,
          onRouter: (r) => router = r,
        ),
      );
      await tester.pumpAndSettle();

      router.go('/admin/exportable_menus');
      await tester.pumpAndSettle();

      expect(find.byType(AdminExportableMenusScreen), findsOneWidget);
    });
  });

  group('AppRouter — deep linking', () {
    testWidgets(
      'should redirect deep link to /login when user is unauthenticated',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        fakeAuth.defaultTryRestoreSessionResponse = const Failure(
          UnauthorizedError(),
        );

        final fakeMenu = FakeMenuRepository();
        _configureMenuRepository(fakeMenu);

        late GoRouter router;

        await tester.pumpWidget(
          _buildApp(
            fakeAuth: fakeAuth,
            fakeMenu: fakeMenu,
            onRouter: (r) => router = r,
          ),
        );
        await tester.pumpAndSettle();

        router.go('/menus/456');
        await tester.pumpAndSettle();

        expect(find.text('OXO Menus'), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsOneWidget);
      },
    );

    // Deep-link to /menus/:id was retired in Phase 12 then reinstated in
    // Phase 24, so the unauthenticated-redirect assertion above still applies
    // (the auth guard fires before the route mounts the editor).

    // Deep-link to /admin/templates/:id was retired in Phase 11 then
    // reinstated in Phase 24. The cutover group above pins the admin-only
    // success path; admin-guard redirects are covered by the admin-guards
    // group earlier in this file.
  });
}
