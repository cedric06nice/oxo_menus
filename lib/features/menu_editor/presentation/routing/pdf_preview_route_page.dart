import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:oxo_menus/core/di/app_container.dart';
import 'package:oxo_menus/core/routing/route_page.dart';
import 'package:oxo_menus/features/menu/data/repositories/column_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/container_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/page_repository_impl.dart';
import 'package:oxo_menus/features/menu/data/repositories/widget_repository_impl.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/generate_pdf_usecase.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/generate_menu_pdf_use_case.dart';
import 'package:oxo_menus/features/menu_editor/presentation/routing/pdf_preview_router.dart';
import 'package:oxo_menus/features/menu_editor/presentation/screens/pdf_preview_screen.dart';
import 'package:oxo_menus/features/menu_editor/presentation/view_models/pdf_preview_view_model.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/shared/data/repositories/asset_loader_repository_impl.dart';
import 'package:oxo_menus/shared/data/repositories/file_repository_impl.dart';

/// View-model factory used by [PdfPreviewRoutePage].
///
/// Tests inject a custom builder to bypass the production repositories. The
/// production path constructs the VM inline inside [PdfPreviewRoutePage]
/// because the wiring needs the route page's `displayOptionsOverride` and
/// `allowedWidgetsOverride` instance fields.
typedef PdfPreviewViewModelBuilder =
    PdfPreviewViewModel Function(
      AppContainer container,
      PdfPreviewRouter router,
      int menuId,
    );

/// Stack entry for the PDF-preview screen.
///
/// Builds the use cases → view model → screen graph from [AppContainer]. The
/// view model is constructed lazily on the first [buildScreen] call and
/// reused across rebuilds; [disposeResources] tears it down when the page
/// leaves the stack for good.
///
/// The optional [displayOptionsOverride] / [allowedWidgetsOverride] inputs
/// let an editor pass live session state when it pushes the preview; deep
/// links arrive without them and fall back to the menu's stored values.
class PdfPreviewRoutePage extends RoutePage {
  PdfPreviewRoutePage({
    required this.router,
    required this.menuId,
    this.displayOptionsOverride,
    this.allowedWidgetsOverride,
    PdfPreviewViewModelBuilder? viewModelBuilder,
  }) : _viewModelBuilder = viewModelBuilder;

  final PdfPreviewRouter router;
  final int menuId;
  final MenuDisplayOptions? displayOptionsOverride;
  final List<WidgetTypeConfig>? allowedWidgetsOverride;
  final PdfPreviewViewModelBuilder? _viewModelBuilder;
  PdfPreviewViewModel? _viewModel;

  @override
  Object get identity => 'pdf-preview-$menuId';

  @override
  Widget buildScreen(AppContainer container) {
    final vm = _viewModel ??= (_viewModelBuilder ?? _defaultBuilder)(
      container,
      router,
      menuId,
    );
    return PdfPreviewScreen(viewModel: vm);
  }

  @override
  void disposeResources() {
    _viewModel?.dispose();
    _viewModel = null;
  }

  PdfPreviewViewModel _defaultBuilder(
    AppContainer container,
    PdfPreviewRouter router,
    int menuId,
  ) {
    final dataSource = container.directusDataSource;
    final menuRepository = MenuRepositoryImpl(dataSource: dataSource);
    final pageRepository = PageRepositoryImpl(dataSource: dataSource);
    final containerRepository = ContainerRepositoryImpl(dataSource: dataSource);
    final columnRepository = ColumnRepositoryImpl(dataSource: dataSource);
    final widgetRepository = WidgetRepositoryImpl(dataSource: dataSource);
    final fileRepository = FileRepositoryImpl(dataSource);
    final assetLoader = AssetLoaderRepositoryImpl();
    final fetchMenuTreeUseCase = FetchMenuTreeUseCase(
      menuRepository: menuRepository,
      pageRepository: pageRepository,
      containerRepository: containerRepository,
      columnRepository: columnRepository,
      widgetRepository: widgetRepository,
    );
    final generatePdfUseCase = GeneratePdfUseCase(
      fileRepository: fileRepository,
      assetLoader: assetLoader,
      useIsolate: !kIsWeb,
    );
    final generateMenuPdfUseCase = GenerateMenuPdfUseCase(
      authGateway: container.authGateway,
      fetchMenuTree: fetchMenuTreeUseCase,
      generatePdf: generatePdfUseCase,
    );
    return PdfPreviewViewModel(
      menuId: menuId,
      generatePdf: generateMenuPdfUseCase,
      router: router,
      displayOptionsOverride: displayOptionsOverride,
      allowedWidgetsOverride: allowedWidgetsOverride,
    );
  }
}
