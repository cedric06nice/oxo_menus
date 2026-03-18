import 'package:flutter/widgets.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';

/// Presentation-layer widget definition that adds Flutter rendering and icons.
///
/// Extends the domain-pure [WidgetDefinition] with:
/// - [render] / [renderDynamic] — returns a Flutter [Widget]
/// - [materialIcon] / [cupertinoIcon] — palette icons
class PresentableWidgetDefinition<P> extends WidgetDefinition<P> {
  /// Render the widget with props and context (type-safe version)
  final Widget Function(P props, WidgetContext context) render;

  /// Material icon for palette and UI display
  final IconData? materialIcon;

  /// Cupertino icon for palette and UI display on Apple platforms
  final IconData? cupertinoIcon;

  const PresentableWidgetDefinition({
    required super.type,
    required super.version,
    required super.parseProps,
    required this.render,
    required super.defaultProps,
    super.migrate,
    super.displayName,
    this.materialIcon,
    this.cupertinoIcon,
  });

  /// Render the widget with dynamic props (type-erased version)
  Widget renderDynamic(dynamic props, WidgetContext context) {
    return render(props as P, context);
  }
}
