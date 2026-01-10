import 'package:oxo_menus/data/models/menu_dto.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';

/// Mapper for converting between Menu entity and MenuDto
class MenuMapper {
  /// Convert MenuDto to Menu entity
  static Menu toEntity(MenuDto dto) {
    return Menu(
      id: dto.id,
      name: dto.name,
      status: _mapStatusToEnum(dto.status),
      version: dto.version,
      dateCreated: dto.dateCreated,
      dateUpdated: dto.dateUpdated,
      userCreated: dto.userCreated,
      userUpdated: dto.userUpdated,
      styleConfig: dto.styleJson != null
          ? _mapStyleJsonToStyleConfig(dto.styleJson!)
          : null,
      pageSize:
          dto.size != null ? _mapSizeJsonToPageSize(dto.size!) : null,
      area: dto.area,
    );
  }

  /// Convert Menu entity to MenuDto
  static MenuDto toDto(Menu entity) {
    return MenuDto(
      id: entity.id,
      name: entity.name,
      status: _mapStatusToString(entity.status),
      version: entity.version,
      dateCreated: entity.dateCreated,
      dateUpdated: entity.dateUpdated,
      userCreated: entity.userCreated,
      userUpdated: entity.userUpdated,
      styleJson: entity.styleConfig != null
          ? _mapStyleConfigToJson(entity.styleConfig!)
          : null,
      size: entity.pageSize != null
          ? _mapPageSizeToJson(entity.pageSize!)
          : null,
      area: entity.area,
    );
  }

  /// Convert CreateMenuInput to Directus format (Map for API)
  static Map<String, dynamic> toCreateDto(CreateMenuInput input) {
    final map = <String, dynamic>{
      'name': input.name,
      'version': input.version,
      'status': input.status != null
          ? _mapStatusToString(input.status!)
          : 'draft', // Default status
    };

    // Only add optional fields if they're not null
    if (input.styleConfig != null) {
      map['style_json'] = _mapStyleConfigToJson(input.styleConfig!);
    }
    if (input.pageSize != null) {
      map['size'] = _mapPageSizeToJson(input.pageSize!);
    }
    if (input.area != null) {
      map['area'] = input.area;
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
      map['status'] = _mapStatusToString(input.status!);
    }
    if (input.styleConfig != null) {
      map['style_json'] = _mapStyleConfigToJson(input.styleConfig!);
    }
    if (input.pageSize != null) {
      map['size'] = _mapPageSizeToJson(input.pageSize!);
    }
    if (input.area != null) {
      map['area'] = input.area;
    }

    return map;
  }

  // ===== Private helper methods =====

  /// Map status string to MenuStatus enum
  static MenuStatus _mapStatusToEnum(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return MenuStatus.draft;
      case 'published':
        return MenuStatus.published;
      case 'archived':
        return MenuStatus.archived;
      default:
        return MenuStatus.draft; // Default fallback
    }
  }

  /// Map MenuStatus enum to status string
  static String _mapStatusToString(MenuStatus status) {
    switch (status) {
      case MenuStatus.draft:
        return 'draft';
      case MenuStatus.published:
        return 'published';
      case MenuStatus.archived:
        return 'archived';
    }
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
  static PageSize _mapSizeJsonToPageSize(Map<String, dynamic> json) {
    return PageSize(
      name: json['name'] as String,
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
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
