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
          ? _mapStyleJsonToStyleConfig(dto.styleJson)
          : null,
      pageSize: _mapSizeDtoToPageSize(sizeDto),
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
          ? _mapStyleConfigToJson(entity.styleConfig!)
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
      map['style_json'] = _mapStyleConfigToJson(input.styleConfig!);
    }
    if (input.sizeId != null) {
      map['size'] = input.sizeId;
    }
    if (input.area != null) {
      map['area'] = _mapAreaStringToId(input.area!);
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
      map['style_json'] = _mapStyleConfigToJson(input.styleConfig!);
    }
    if (input.pageSize != null) {
      map['size'] = _mapPageSizeToJson(input.pageSize!);
    }
    if (input.area != null) {
      map['area'] = _mapAreaStringToId(input.area!);
    }

    return map;
  }

  /// Map style_json to StyleConfig entity
  static StyleConfig _mapStyleJsonToStyleConfig(Map<String, dynamic> json) {
    return StyleConfig(
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      primaryColor: json['primaryColor'] as String?,
      secondaryColor: json['secondaryColor'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      marginTop: (json['marginTop'] as num?)?.toDouble(),
      marginBottom: (json['marginBottom'] as num?)?.toDouble(),
      marginLeft: (json['marginLeft'] as num?)?.toDouble(),
      marginRight: (json['marginRight'] as num?)?.toDouble(),
      padding: (json['padding'] as num?)?.toDouble(),
    );
  }

  /// Map StyleConfig entity to JSON
  static Map<String, dynamic> _mapStyleConfigToJson(StyleConfig config) {
    final map = <String, dynamic>{};

    if (config.fontFamily != null) map['fontFamily'] = config.fontFamily;
    if (config.fontSize != null) map['fontSize'] = config.fontSize;
    if (config.primaryColor != null) map['primaryColor'] = config.primaryColor;
    if (config.secondaryColor != null) {
      map['secondaryColor'] = config.secondaryColor;
    }
    if (config.backgroundColor != null) {
      map['backgroundColor'] = config.backgroundColor;
    }
    if (config.marginTop != null) map['marginTop'] = config.marginTop;
    if (config.marginBottom != null) map['marginBottom'] = config.marginBottom;
    if (config.marginLeft != null) map['marginLeft'] = config.marginLeft;
    if (config.marginRight != null) map['marginRight'] = config.marginRight;
    if (config.padding != null) map['padding'] = config.padding;

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
