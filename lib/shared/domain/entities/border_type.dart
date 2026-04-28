import 'package:freezed_annotation/freezed_annotation.dart';

enum BorderType {
  @JsonValue('none')
  none,
  @JsonValue('plain_thin')
  plainThin,
  @JsonValue('plain_thick')
  plainThick,
  @JsonValue('double_offset')
  doubleOffset,
  @JsonValue('drop_shadow')
  dropShadow;

  String get label => switch (this) {
    none => 'No Border',
    plainThin => 'Plain Thin',
    plainThick => 'Plain Thick',
    doubleOffset => 'Offset Double Border',
    dropShadow => 'Drop Shadow',
  };
}

extension BorderTypeConverter on BorderType {
  static BorderType fromString(String value) {
    switch (value) {
      case 'none':
        return BorderType.none;
      case 'plain_thin':
        return BorderType.plainThin;
      case 'plain_thick':
        return BorderType.plainThick;
      case 'double_offset':
        return BorderType.doubleOffset;
      case 'drop_shadow':
        return BorderType.dropShadow;
      default:
        return BorderType.none;
    }
  }

  static String toJsonString(BorderType type) {
    switch (type) {
      case BorderType.none:
        return 'none';
      case BorderType.plainThin:
        return 'plain_thin';
      case BorderType.plainThick:
        return 'plain_thick';
      case BorderType.doubleOffset:
        return 'double_offset';
      case BorderType.dropShadow:
        return 'drop_shadow';
    }
  }
}
