import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';

part 'widget_type_config.freezed.dart';
part 'widget_type_config.g.dart';

/// Template-level configuration for an authorised widget type.
///
/// Persisted in `Menu.allowedWidgets`. Carries the widget type string and the
/// alignment that admins selected for that type within the template.
@freezed
abstract class WidgetTypeConfig with _$WidgetTypeConfig {
  const WidgetTypeConfig._();

  const factory WidgetTypeConfig({
    required String type,
    @Default(WidgetAlignment.start) WidgetAlignment alignment,

    /// Whether this widget type is currently available to regular users.
    /// Admins can configure [alignment] without enabling the type.
    @Default(true) bool enabled,
  }) = _WidgetTypeConfig;

  factory WidgetTypeConfig.fromJson(Map<String, dynamic> json) =>
      _$WidgetTypeConfigFromJson(json);
}
