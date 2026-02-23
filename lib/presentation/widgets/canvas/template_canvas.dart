import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/presentation/widgets/canvas/widget_renderer.dart';

/// Template Canvas
///
/// Renders the full menu template with all pages, containers, columns, and widgets.
/// This component provides a visual representation of the menu structure and can be
/// used in both editable (menu editor) and read-only (preview) modes.
class TemplateCanvas extends ConsumerWidget {
  final MenuTree menuTree;
  final bool isEditable;
  final VoidCallback? onWidgetTap;

  const TemplateCanvas({
    super.key,
    required this.menuTree,
    this.isEditable = false,
    this.onWidgetTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If there are no pages, show empty state
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

    // Single page: show directly without PageView
    if (menuTree.pages.length == 1) {
      return PageCanvas(
        page: menuTree.pages.first,
        headerPage: menuTree.headerPage,
        footerPage: menuTree.footerPage,
        isEditable: isEditable,
      );
    }

    // Multiple pages: use PageView for swipe navigation
    return PageView.builder(
      itemCount: menuTree.pages.length,
      itemBuilder: (context, pageIndex) {
        final pageData = menuTree.pages[pageIndex];
        return PageCanvas(
          page: pageData,
          headerPage: menuTree.headerPage,
          footerPage: menuTree.footerPage,
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
  final bool isEditable;

  const PageCanvas({
    super.key,
    required this.page,
    this.headerPage,
    this.footerPage,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header containers
          if (headerPage != null)
            ...headerPage!.containers.map((containerData) {
              return ContainerCanvas(
                container: containerData,
                isEditable: isEditable,
              );
            }),

          // Page title (optional, can be shown or hidden based on design)
          if (isEditable)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                page.page.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

          // Content containers
          ...page.containers.map((containerData) {
            return ContainerCanvas(
              container: containerData,
              isEditable: isEditable,
            );
          }),

          // Footer containers
          if (footerPage != null)
            ...footerPage!.containers.map((containerData) {
              return ContainerCanvas(
                container: containerData,
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
  final bool isEditable;

  const ContainerCanvas({
    super.key,
    required this.container,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container name (optional header)
          if (container.container.name != null && isEditable)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                container.container.name!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

          // Columns in a row
          if (container.columns.isNotEmpty)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: container.columns.map((columnData) {
                  final column = columnData.column;
                  return Expanded(
                    flex: column.flex ?? 1,
                    child: ColumnCanvas(
                      column: columnData,
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
}

/// Column Canvas
///
/// Renders a column with its widgets.
class ColumnCanvas extends ConsumerWidget {
  final ColumnWithWidgets column;
  final bool isEditable;

  const ColumnCanvas({
    super.key,
    required this.column,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        children: [
          // Widgets
          ...column.widgets.map((widget) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: WidgetRenderer(
                widgetInstance: widget,
                isEditable: isEditable,
              ),
            );
          }),

          // Empty state for editable mode
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
}
