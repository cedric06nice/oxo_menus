import 'package:oxo_menus/data/mappers/display_options_mapper.dart';
import 'package:oxo_menus/data/mappers/style_config_mapper.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';
import 'package:oxo_menus/data/models/size_dto.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';

/// Mapper for converting between Menu entity and MenuDto
class MenuMapper {
  /// Convert MenuDto to Menu entity
  static Menu toEntity(MenuDto dto) {
    String idString = dto.id ?? '0';
    final sizeDto = dto.size;
    return Menu(
      id: int.parse(idString),
      name: dto.name,
      status: StatusConverter.mapStatusToEnum(dto.status),
      version: dto.version,
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
      userCreated: dto.userCreated,
      userUpdated: dto.userUpdated,
      styleConfig: dto.styleJson.isNotEmpty
          ? StyleConfigMapper.fromJson(dto.styleJson)
          : null,
      pageSize: _mapSizeDtoToPageSize(sizeDto),
      displayOptions: dto.displayOptionsJson.isNotEmpty
          ? DisplayOptionsMapper.fromJson(dto.displayOptionsJson)
          : null,
    );
  }

  /// Map SizeDto to PageSize entity (returns null if SizeDto only has ID, no data)
  static PageSize? _mapSizeDtoToPageSize(SizeDto? sizeDto) {
    if (sizeDto == null) return null;
    // Check if the SizeDto has actual data (not just an ID reference)
    // When created with SizeDto.withId(), the raw data only contains 'id'
    final rawData = sizeDto.getRawData();
    if (!rawData.containsKey('name') ||
        !rawData.containsKey('width') ||
        !rawData.containsKey('height')) {
      return null;
    }
    return PageSize(
      name: sizeDto.name,
      width: sizeDto.width,
      height: sizeDto.height,
    );
  }

  /// Convert Menu entity to MenuDto
  static MenuDto toDto(Menu entity) {
    return MenuDto({
      'id': entity.id,
      'name': entity.name,
      'status': StatusConverter.mapStatusToString(entity.status),
      'date_created': entity.dateCreated,
      'date_updated': entity.dateUpdated,
      'user_created': entity.userCreated,
      'user_updated': entity.userUpdated,
      'version': entity.version,
      'style_json': entity.styleConfig != null
          ? StyleConfigMapper.toJson(entity.styleConfig!)
          : null,
      'size': entity.pageSize != null
          ? _mapPageSizeToJson(entity.pageSize!)
          : null,
      'area': entity.area != null ? _mapAreaStringToId(entity.area!) : null,
      'versions': null,
      'pages': null,
    });
  }

  /// Convert CreateMenuInput to Directus format (Map for API)
  static Map<String, dynamic> toCreateDto(CreateMenuInput input) {
    final map = <String, dynamic>{
      'name': input.name,
      'version': input.version,
      'status': input.status != null
          ? StatusConverter.mapStatusToString(input.status!)
          : 'draft', // Default status
    };

    // Only add optional fields if they're not null
    if (input.styleConfig != null) {
      map['style_json'] = StyleConfigMapper.toJson(input.styleConfig!);
    }
    if (input.sizeId != null) {
      map['size'] = input.sizeId;
    }
    if (input.area != null) {
      map['area'] = _mapAreaStringToId(input.area!);
    }
    if (input.displayOptions != null) {
      map['display_options_json'] = DisplayOptionsMapper.toJson(
        input.displayOptions!,
      );
    }

    return map;
  }

  /// Convert UpdateMenuInput to Directus format (Map for API)
  static Map<String, dynamic> toUpdateDto(UpdateMenuInput input) {
    final map = <String, dynamic>{};

    // Only include fields that are not null
    if (input.name != null) {
      map['name'] = input.name;
    }
    if (input.version != null) {
      map['version'] = input.version;
    }
    if (input.status != null) {
      map['status'] = StatusConverter.mapStatusToString(input.status!);
    }
    if (input.styleConfig != null) {
      map['style_json'] = StyleConfigMapper.toJson(input.styleConfig!);
    }
    if (input.pageSize != null) {
      map['size'] = _mapPageSizeToJson(input.pageSize!);
    }
    if (input.area != null) {
      map['area'] = _mapAreaStringToId(input.area!);
    }
    if (input.displayOptions != null) {
      map['display_options_json'] = DisplayOptionsMapper.toJson(
        input.displayOptions!,
      );
    }

    return map;
  }

  /// Map size JSON to PageSize entity
  // static PageSize _mapSizeJsonToPageSize(Map<String, dynamic> json) {
  //   return PageSize(
  //     name: json['name'] as String,
  //     width: (json['width'] as num).toDouble(),
  //     height: (json['height'] as num).toDouble(),
  //   );
  // }

  /// Map PageSize entity to JSON
  static Map<String, dynamic> _mapPageSizeToJson(PageSize pageSize) {
    return {
      'name': pageSize.name,
      'width': pageSize.width,
      'height': pageSize.height,
    };
  }

  /// Map area string (name) to int (ID) for Directus
  static int? _mapAreaStringToId(String areaName) {
    const areaIdMap = {'dining': 1, 'bar': 2, 'terrace': 3, 'takeaway': 4};
    return areaIdMap[areaName.toLowerCase()];
  }
}
