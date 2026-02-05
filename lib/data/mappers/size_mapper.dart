import 'package:oxo_menus/data/models/size_dto.dart';
import 'package:oxo_menus/domain/entities/size.dart';

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
    );
  }
}
