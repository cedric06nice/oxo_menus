import 'package:freezed_annotation/freezed_annotation.dart';

enum VerticalAlignment {
  @JsonValue('top')
  top,
  @JsonValue('center')
  center,
  @JsonValue('bottom')
  bottom;

  String get label => switch (this) {
    top => 'Top',
    center => 'Center',
    bottom => 'Bottom',
  };
}

extension VerticalAlignmentConverter on VerticalAlignment {
  static VerticalAlignment fromString(String value) {
    switch (value) {
      case 'top':
        return VerticalAlignment.top;
      case 'center':
        return VerticalAlignment.center;
      case 'bottom':
        return VerticalAlignment.bottom;
      default:
        return VerticalAlignment.top;
    }
  }

  static String toJsonString(VerticalAlignment type) {
    switch (type) {
      case VerticalAlignment.top:
        return 'top';
      case VerticalAlignment.center:
        return 'center';
      case VerticalAlignment.bottom:
        return 'bottom';
    }
  }
}
