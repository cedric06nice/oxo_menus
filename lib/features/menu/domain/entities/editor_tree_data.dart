import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';

/// Flattened editor tree returned by the menu / template load use cases.
///
/// Mirrors the shape the legacy `editor_tree` Riverpod state used so the
/// migrated screens can render with index-keyed lookups. Header / footer pages
/// are split out from the content pages so the UI can render the dedicated
/// header / footer slots without filtering on every rebuild.
///
/// Lives in the menu domain so it can be shared by every editor feature
/// (admin template editor, menu editor) without violating cross-feature
/// isolation.
class EditorTreeData {
  const EditorTreeData({
    required this.menu,
    required this.pages,
    required this.headerPage,
    required this.footerPage,
    required this.containers,
    required this.childContainers,
    required this.columns,
    required this.widgets,
  });

  final Menu menu;
  final List<entity.Page> pages;
  final entity.Page? headerPage;
  final entity.Page? footerPage;
  final Map<int, List<entity.Container>> containers;
  final Map<int, List<entity.Container>> childContainers;
  final Map<int, List<entity.Column>> columns;
  final Map<int, List<WidgetInstance>> widgets;
}
