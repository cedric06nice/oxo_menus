import 'package:freezed_annotation/freezed_annotation.dart';

part 'container.freezed.dart';
part 'container.g.dart';

/// Represents a section/container on a page (horizontal grouping of columns).
@freezed
class Container with _$Container {
  const Container._();

  const factory Container({
    required String id,
    required String pageId,
    required int index,
    String? name,
    LayoutConfig? layout,
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) = _Container;

  factory Container.fromJson(Map<String, dynamic> json) =>
      _$ContainerFromJson(json);
}

/// Layout configuration for a container
@freezed
class LayoutConfig with _$LayoutConfig {
  const LayoutConfig._();

  const factory LayoutConfig({
    String? direction,
    String? alignment,
    double? spacing,
  }) = _LayoutConfig;

  factory LayoutConfig.fromJson(Map<String, dynamic> json) =>
      _$LayoutConfigFromJson(json);
}
