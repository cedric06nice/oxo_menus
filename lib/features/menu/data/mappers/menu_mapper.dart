import 'package:oxo_menus/features/menu/data/mappers/display_options_mapper.dart';
import 'package:oxo_menus/features/menu/data/mappers/style_config_mapper.dart';
import 'package:oxo_menus/shared/data/models/area_dto.dart';
import 'package:oxo_menus/features/menu/data/models/menu_dto.dart';
import 'package:oxo_menus/features/menu/data/models/size_dto.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/features/menu/domain/repositories/menu_repository.dart';

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
      area: _mapAreaDtoToArea(dto.area),
      displayOptions: dto.displayOptionsJson.isNotEmpty
          ? DisplayOptionsMapper.fromJson(dto.displayOptionsJson)
          : null,
      allowedWidgets: dto.allowedWidgets,
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

  /// Map AreaDto to Area entity (returns null if AreaDto only has ID, no name data)
  static Area? _mapAreaDtoToArea(AreaDto? areaDto) {
    if (areaDto == null) return null;
    final rawData = areaDto.getRawData();
    if (!rawData.containsKey('name')) return null;
    final idString = areaDto.id ?? '0';
    return Area(id: int.parse(idString), name: areaDto.name);
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
      'area': entity.area?.id,
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
    if (input.areaId != null) {
      map['area'] = input.areaId;
    }
    if (input.displayOptions != null) {
      map['display_options_json'] = DisplayOptionsMapper.toJson(
        input.displayOptions!,
      );
    }
    if (input.allowedWidgets != null) {
      map['allowed_widgets'] = input.allowedWidgets!
          .map((c) => c.toJson())
          .toList();
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
    if (input.sizeId != null) {
      map['size'] = input.sizeId;
    }
    if (input.areaId != null) {
      map['area'] = input.areaId;
    }
    if (input.displayOptions != null) {
      map['display_options_json'] = DisplayOptionsMapper.toJson(
        input.displayOptions!,
      );
    }
    if (input.allowedWidgets != null) {
      map['allowed_widgets'] = input.allowedWidgets!
          .map((c) => c.toJson())
          .toList();
    }

    return map;
  }

  /// Map PageSize entity to JSON
  static Map<String, dynamic> _mapPageSizeToJson(PageSize pageSize) {
    return {
      'name': pageSize.name,
      'width': pageSize.width,
      'height': pageSize.height,
    };
  }
}
