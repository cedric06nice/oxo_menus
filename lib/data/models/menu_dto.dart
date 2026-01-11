import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_dto.freezed.dart';
part 'menu_dto.g.dart';

/// Data Transfer Object for Menu matching Directus 'menu' collection schema
@freezed
abstract class MenuDto with _$MenuDto {
  const MenuDto._();
  const factory MenuDto({
    required String id,
    required String status,
    @JsonKey(name: 'date_created') DateTime? dateCreated,
    @JsonKey(name: 'date_updated') DateTime? dateUpdated,
    @JsonKey(name: 'user_created') String? userCreated,
    @JsonKey(name: 'user_updated') String? userUpdated,
    required String name,
    required String version,
    @JsonKey(name: 'style_json') Map<String, dynamic>? styleJson,
    String? area,
    Map<String, dynamic>? size,
  }) = _MenuDto;

  factory MenuDto.fromJson(Map<String, dynamic> json) =>
      _$MenuDtoFromJson(json);
}
