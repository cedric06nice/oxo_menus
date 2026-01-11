import 'package:freezed_annotation/freezed_annotation.dart';

part 'column_dto.freezed.dart';
part 'column_dto.g.dart';

/// Data Transfer Object for Column matching Directus 'column' collection schema
@freezed
abstract class ColumnDto with _$ColumnDto {
  const ColumnDto._();
  const factory ColumnDto({
    required String id,
    @JsonKey(name: 'date_created') DateTime? dateCreated,
    @JsonKey(name: 'date_updated') DateTime? dateUpdated,
    @JsonKey(name: 'container_id') required String containerId,
    required int index,
    int? flex,
    double? width,
  }) = _ColumnDto;

  factory ColumnDto.fromJson(Map<String, dynamic> json) =>
      _$ColumnDtoFromJson(json);
}
