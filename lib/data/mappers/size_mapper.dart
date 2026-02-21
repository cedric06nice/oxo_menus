import 'package:oxo_menus/data/models/size_dto.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';

/// Mapper for converting between Size entity and SizeDto
class SizeMapper {
  /// Convert SizeDto to Size entity
  static Size toEntity(SizeDto dto) {
    final idString = dto.id ?? '0';
    return Size(
      id: int.parse(idString),
      name: dto.name,
      width: dto.width,
      height: dto.height,
      status: StatusConverter.mapStatusToEnum(dto.status),
      direction: dto.direction,
    );
  }

  /// Convert CreateSizeInput to Directus format map
  static Map<String, dynamic> toCreateDto(CreateSizeInput input) {
    return {
      'name': input.name,
      'width': input.width,
      'height': input.height,
      'status': StatusConverter.mapStatusToString(input.status),
      'direction': input.direction,
    };
  }

  /// Convert UpdateSizeInput to Directus format map (only non-null fields)
  static Map<String, dynamic> toUpdateDto(UpdateSizeInput input) {
    final map = <String, dynamic>{};

    if (input.name != null) map['name'] = input.name;
    if (input.width != null) map['width'] = input.width;
    if (input.height != null) map['height'] = input.height;
    if (input.status != null) {
      map['status'] = StatusConverter.mapStatusToString(input.status!);
    }
    if (input.direction != null) map['direction'] = input.direction;

    return map;
  }
}
