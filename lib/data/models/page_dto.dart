import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_dto.freezed.dart';
part 'page_dto.g.dart';

/// Data Transfer Object for Page matching Directus 'page' collection schema
@freezed
class PageDto with _$PageDto {
  const PageDto._();
  const factory PageDto({
    required String id,
    @JsonKey(name: 'date_created') DateTime? dateCreated,
    @JsonKey(name: 'date_updated') DateTime? dateUpdated,
    @JsonKey(name: 'menu_id') required String menuId,
    required String name,
    required int index,
  }) = _PageDto;

  factory PageDto.fromJson(Map<String, dynamic> json) =>
      _$PageDtoFromJson(json);
}
