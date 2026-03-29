import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

part 'container.freezed.dart';
part 'container.g.dart';

/// Represents a section/container on a page (horizontal grouping of columns).
@freezed
abstract class Container with _$Container {
  const Container._();

  const factory Container({
    required int id,
    required int pageId,
    required int index,
    String? name,
    int? parentContainerId,
    LayoutConfig? layout,
    StyleConfig? styleConfig,
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) = _Container;

  factory Container.fromJson(Map<String, dynamic> json) =>
      _$ContainerFromJson(json);
}

/// Layout configuration for a container
@freezed
abstract class LayoutConfig with _$LayoutConfig {
  const LayoutConfig._();

  const factory LayoutConfig({
    String? direction,
    String? alignment,
    String? mainAxisAlignment,
    double? spacing,
  }) = _LayoutConfig;

  factory LayoutConfig.fromJson(Map<String, dynamic> json) =>
      _$LayoutConfigFromJson(json);
}
