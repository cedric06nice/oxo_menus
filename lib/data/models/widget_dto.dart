import 'package:freezed_annotation/freezed_annotation.dart';

part 'widget_dto.freezed.dart';
part 'widget_dto.g.dart';

/// Data Transfer Object for Widget matching Directus 'widget' collection schema
@freezed
class WidgetDto with _$WidgetDto {
  const factory WidgetDto({
    required String id,
    @JsonKey(name: 'date_created') DateTime? dateCreated,
    @JsonKey(name: 'date_updated') DateTime? dateUpdated,
    @JsonKey(name: 'column_id') required String columnId,
    required String type,
    required String version,
    required int index,
    required Map<String, dynamic> props,
    @JsonKey(name: 'style_json') Map<String, dynamic>? styleJson,
  }) = _WidgetDto;

  factory WidgetDto.fromJson(Map<String, dynamic> json) =>
      _$WidgetDtoFromJson(json);
}
