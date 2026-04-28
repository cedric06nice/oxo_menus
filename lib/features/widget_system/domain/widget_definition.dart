import 'package:oxo_menus/core/gateways/image_gateway.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';

/// Context provided to widgets during rendering
///
/// Contains runtime information about the widget's editing state
/// and callbacks for updates and deletion.
class WidgetContext {
  /// Whether the widget is in editable mode
  final bool isEditable;

  /// Callback to update widget props
  final void Function(Map<String, dynamic>)? onUpdate;

  /// Callback to delete the widget
  final void Function()? onDelete;

  /// Callback when widget editing starts (e.g., to acquire a lock)
  final void Function()? onEditStarted;

  /// Callback when widget editing ends (e.g., to release a lock)
  final void Function()? onEditEnded;

  /// Menu-level display options
  final MenuDisplayOptions? displayOptions;

  /// Template-level alignment applied to this widget's content.
  final WidgetAlignment alignment;

  /// Gateway used by image-bearing widgets (currently `image`) to load bytes
  /// and list available images. Optional — widgets that don't need image data
  /// ignore it.
  final ImageGateway? imageGateway;

  const WidgetContext({
    required this.isEditable,
    this.onUpdate,
    this.onDelete,
    this.onEditStarted,
    this.onEditEnded,
    this.displayOptions,
    this.alignment = WidgetAlignment.start,
    this.imageGateway,
  });
}

/// Domain-pure widget definition with type-safe props.
///
/// This class defines a widget type's data behavior:
/// - Parsing JSON props into typed objects
/// - Providing default props for new instances
/// - Optional migration function for version upgrades
///
/// Rendering and UI concerns (icons, Flutter widgets) are handled
/// by [PresentableWidgetDefinition] in the presentation layer.
class WidgetDefinition<P> {
  /// Unique widget type identifier (e.g., 'dish', 'section')
  final String type;

  /// Semantic version for this widget (e.g., '1.0.0')
  final String version;

  /// Parse JSON props into typed props object
  final P Function(Map<String, dynamic>) parseProps;

  /// Default props for new instances
  final P defaultProps;

  /// Optional migration function for version upgrades
  final P Function(Map<String, dynamic>)? migrate;

  /// Human-readable display name (e.g., 'Dish', 'Wine')
  ///
  /// Falls back to [type] if not provided.
  final String? displayName;

  const WidgetDefinition({
    required this.type,
    required this.version,
    required this.parseProps,
    required this.defaultProps,
    this.migrate,
    this.displayName,
  });
}
