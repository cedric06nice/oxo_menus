import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

/// Shared mapper for converting between StyleConfig and JSON.
/// Reused by MenuMapper, ContainerMapper, and ColumnMapper.
class StyleConfigMapper {
  /// Parse a JSON map into a StyleConfig entity.
  static StyleConfig fromJson(Map<String, dynamic> json) {
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
      paddingTop: (json['paddingTop'] as num?)?.toDouble(),
      paddingBottom: (json['paddingBottom'] as num?)?.toDouble(),
      paddingLeft: (json['paddingLeft'] as num?)?.toDouble(),
      paddingRight: (json['paddingRight'] as num?)?.toDouble(),
      borderType: json['borderType'] != null
          ? BorderTypeConverter.fromString(json['borderType'] as String)
          : null,
    );
  }

  /// Serialize a StyleConfig entity to JSON, omitting null fields.
  static Map<String, dynamic> toJson(StyleConfig config) {
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
    if (config.paddingTop != null) map['paddingTop'] = config.paddingTop;
    if (config.paddingBottom != null) {
      map['paddingBottom'] = config.paddingBottom;
    }
    if (config.paddingLeft != null) map['paddingLeft'] = config.paddingLeft;
    if (config.paddingRight != null) map['paddingRight'] = config.paddingRight;
    if (config.borderType != null) {
      map['borderType'] = BorderTypeConverter.toJsonString(config.borderType!);
    }

    return map;
  }
}
