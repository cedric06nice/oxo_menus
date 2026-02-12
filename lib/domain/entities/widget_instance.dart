import 'package:freezed_annotation/freezed_annotation.dart';

part 'widget_instance.freezed.dart';
part 'widget_instance.g.dart';

/// Represents a widget instance placed in a column.
@freezed
abstract class WidgetInstance with _$WidgetInstance {
  const WidgetInstance._();

  const factory WidgetInstance({
    required int id,
    required int columnId,
    required String type,
    required String version,
    required int index,
    required Map<String, dynamic> props,
    WidgetStyle? style,
    @Default(false) bool isTemplate,
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) = _WidgetInstance;

  factory WidgetInstance.fromJson(Map<String, dynamic> json) =>
      _$WidgetInstanceFromJson(json);
}

/// Widget-specific styling overrides
@freezed
abstract class WidgetStyle with _$WidgetStyle {
  const WidgetStyle._();

  const factory WidgetStyle({
    String? fontFamily,
    double? fontSize,
    String? color,
    String? backgroundColor,
    String? border,
    double? padding,
  }) = _WidgetStyle;

  factory WidgetStyle.fromJson(Map<String, dynamic> json) =>
      _$WidgetStyleFromJson(json);
}
