import 'package:oxo_menus/domain/entities/widget_instance.dart';
import 'widget_definition.dart';

/// Handles widget props migration across versions
///
/// The WidgetMigrator provides utilities for migrating widget props
/// when a widget instance has an older version than its definition.
/// This enables backward compatibility when widget schemas evolve.
class WidgetMigrator {
  /// Migrate widget props using the definition's migrate function
  ///
  /// If the definition has a migration function, it will be called
  /// to transform the props. If migration fails, the original props
  /// are returned unchanged.
  ///
  /// Returns the migrated props as a Map<String, dynamic>.
  static Map<String, dynamic> migrate(
    WidgetInstance instance,
    WidgetDefinition definition,
  ) {
    var props = instance.props;

    // If there's a migrate function, apply it
    if (definition.migrate != null) {
      try {
        final migratedProps = definition.migrate!(props);
        // Convert migrated props back to Map
        props = (migratedProps as dynamic).toJson();
      } catch (e) {
        // If migration fails, return original props
        // In production, this should log the error
        return props;
      }
    }

    return props;
  }

  /// Check if migration is needed
  ///
  /// Returns true if the widget instance version differs from
  /// the definition version, indicating that migration should be performed.
  static bool needsMigration(
    WidgetInstance instance,
    WidgetDefinition definition,
  ) {
    return instance.version != definition.version;
  }
}
