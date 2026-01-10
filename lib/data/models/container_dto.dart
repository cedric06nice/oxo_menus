import 'package:freezed_annotation/freezed_annotation.dart';

part 'container_dto.freezed.dart';
part 'container_dto.g.dart';

/// Data Transfer Object for Container matching Directus 'container' collection schema
@freezed
class ContainerDto with _$ContainerDto {
  const factory ContainerDto({
    required String id,
    @JsonKey(name: 'date_created') DateTime? dateCreated,
    @JsonKey(name: 'date_updated') DateTime? dateUpdated,
    @JsonKey(name: 'page_id') required String pageId,
    required int index,
    String? name,
    @JsonKey(name: 'layout_json') Map<String, dynamic>? layoutJson,
  }) = _ContainerDto;

  factory ContainerDto.fromJson(Map<String, dynamic> json) =>
      _$ContainerDtoFromJson(json);
}
