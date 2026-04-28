import 'package:flutter/material.dart';
import 'package:oxo_menus/core/gateways/image_gateway.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/canvas/widget_renderer.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';
import 'package:oxo_menus/shared/domain/entities/vertical_alignment.dart';

/// Template Canvas
///
/// Renders the full menu template with all pages, containers, columns, and widgets.
/// Used in both editable (menu editor) and read-only (preview) modes.
///
/// Plain [StatelessWidget]: takes [registry], [displayOptions], and
/// [allowedWidgets] as constructor args and forwards them to every nested
/// [WidgetRenderer].
class TemplateCanvas extends StatelessWidget {
  final MenuTree menuTree;
  final PresentableWidgetRegistry registry;
  final MenuDisplayOptions? displayOptions;
  final List<WidgetTypeConfig> allowedWidgets;
  final ImageGateway? imageGateway;
  final bool isEditable;
  final VoidCallback? onWidgetTap;

  const TemplateCanvas({
    super.key,
    required this.menuTree,
    required this.registry,
    this.displayOptions,
    this.allowedWidgets = const [],
    this.imageGateway,
    this.isEditable = false,
    this.onWidgetTap,
  });

  @override
  Widget build(BuildContext context) {
    if (menuTree.pages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No pages in this menu',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    if (menuTree.pages.length == 1) {
      return PageCanvas(
        page: menuTree.pages.first,
        headerPage: menuTree.headerPage,
        footerPage: menuTree.footerPage,
        registry: registry,
        displayOptions: displayOptions,
        allowedWidgets: allowedWidgets,
        imageGateway: imageGateway,
        isEditable: isEditable,
      );
    }

    return PageView.builder(
      itemCount: menuTree.pages.length,
      itemBuilder: (context, pageIndex) {
        final pageData = menuTree.pages[pageIndex];
        return PageCanvas(
          page: pageData,
          headerPage: menuTree.headerPage,
          footerPage: menuTree.footerPage,
          registry: registry,
          displayOptions: displayOptions,
          allowedWidgets: allowedWidgets,
          imageGateway: imageGateway,
          isEditable: isEditable,
        );
      },
    );
  }
}

/// Page Canvas
///
/// Renders a single page with all its containers, including optional header and footer.
class PageCanvas extends StatelessWidget {
  final PageWithContainers page;
  final PageWithContainers? headerPage;
  final PageWithContainers? footerPage;
  final PresentableWidgetRegistry registry;
  final MenuDisplayOptions? displayOptions;
  final List<WidgetTypeConfig> allowedWidgets;
  final ImageGateway? imageGateway;
  final bool isEditable;

  const PageCanvas({
    super.key,
    required this.page,
    this.headerPage,
    this.footerPage,
    required this.registry,
    this.displayOptions,
    this.allowedWidgets = const [],
    this.imageGateway,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headerPage != null)
            ...headerPage!.containers.map((containerData) {
              return ContainerCanvas(
                container: containerData,
                registry: registry,
                displayOptions: displayOptions,
                allowedWidgets: allowedWidgets,
                imageGateway: imageGateway,
                isEditable: isEditable,
              );
            }),

          if (isEditable)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                page.page.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

          ...page.containers.map((containerData) {
            return ContainerCanvas(
              container: containerData,
              registry: registry,
              displayOptions: displayOptions,
              allowedWidgets: allowedWidgets,
              imageGateway: imageGateway,
              isEditable: isEditable,
            );
          }),

          if (footerPage != null)
            ...footerPage!.containers.map((containerData) {
              return ContainerCanvas(
                container: containerData,
                registry: registry,
                displayOptions: displayOptions,
                allowedWidgets: allowedWidgets,
                imageGateway: imageGateway,
                isEditable: isEditable,
              );
            }),
        ],
      ),
    );
  }
}

/// Container Canvas
///
/// Renders a container (section) with its columns in a horizontal layout.
class ContainerCanvas extends StatelessWidget {
  final ContainerWithColumns container;
  final PresentableWidgetRegistry registry;
  final MenuDisplayOptions? displayOptions;
  final List<WidgetTypeConfig> allowedWidgets;
  final ImageGateway? imageGateway;
  final bool isEditable;

  const ContainerCanvas({
    super.key,
    required this.container,
    required this.registry,
    this.displayOptions,
    this.allowedWidgets = const [],
    this.imageGateway,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (container.container.name != null && isEditable)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                container.container.name!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

          if (container.children.isNotEmpty) _buildChildContainers(),

          if (container.children.isEmpty && container.columns.isNotEmpty)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: container.columns.map((columnData) {
                  final column = columnData.column;
                  return Expanded(
                    flex: column.flex ?? 1,
                    child: ColumnCanvas(
                      column: columnData,
                      registry: registry,
                      displayOptions: displayOptions,
                      allowedWidgets: allowedWidgets,
                      imageGateway: imageGateway,
                      isEditable: isEditable,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChildContainers() {
    final direction = container.container.layout?.direction;
    final mainAxisAlignment = _resolveMainAxisAlignment(
      container.container.layout?.mainAxisAlignment,
    );

    final childWidgets = container.children
        .map(
          (child) => ContainerCanvas(
            container: child,
            registry: registry,
            displayOptions: displayOptions,
            allowedWidgets: allowedWidgets,
            imageGateway: imageGateway,
            isEditable: isEditable,
          ),
        )
        .toList();

    if (direction == 'row') {
      return IntrinsicHeight(
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: childWidgets.map((w) => Expanded(child: w)).toList(),
        ),
      );
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: childWidgets,
    );
  }

  static MainAxisAlignment _resolveMainAxisAlignment(String? value) {
    return switch (value) {
      'end' => MainAxisAlignment.end,
      'center' => MainAxisAlignment.center,
      'spaceBetween' => MainAxisAlignment.spaceBetween,
      'spaceAround' => MainAxisAlignment.spaceAround,
      'spaceEvenly' => MainAxisAlignment.spaceEvenly,
      _ => MainAxisAlignment.start,
    };
  }
}

/// Column Canvas
///
/// Renders a column with its widgets.
class ColumnCanvas extends StatelessWidget {
  final ColumnWithWidgets column;
  final PresentableWidgetRegistry registry;
  final MenuDisplayOptions? displayOptions;
  final List<WidgetTypeConfig> allowedWidgets;
  final ImageGateway? imageGateway;
  final bool isEditable;

  const ColumnCanvas({
    super.key,
    required this.column,
    required this.registry,
    this.displayOptions,
    this.allowedWidgets = const [],
    this.imageGateway,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: isEditable ? colorScheme.outlineVariant : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: _getMainAxisAlignment(),
        children: [
          ...column.widgets.map((widget) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: WidgetRenderer(
                widgetInstance: widget,
                registry: registry,
                displayOptions: displayOptions,
                allowedWidgets: allowedWidgets,
                imageGateway: imageGateway,
                isEditable: isEditable,
              ),
            );
          }),

          if (isEditable && column.widgets.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Empty column',
                  style: TextStyle(color: colorScheme.outline, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  MainAxisAlignment _getMainAxisAlignment() {
    final va = column.column.styleConfig?.verticalAlignment;
    return switch (va) {
      VerticalAlignment.center => MainAxisAlignment.center,
      VerticalAlignment.bottom => MainAxisAlignment.end,
      _ => MainAxisAlignment.start,
    };
  }
}
