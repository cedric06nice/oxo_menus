import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';

/// Builds a [Size] with sensible test defaults.
///
/// ```dart
/// final size = buildSize(name: 'A5', width: 148.0, height: 210.0);
/// ```
Size buildSize({
  int id = 1,
  String name = 'A4',
  double width = 210.0,
  double height = 297.0,
  Status status = Status.published,
  String direction = 'portrait',
}) {
  return Size(
    id: id,
    name: name,
    width: width,
    height: height,
    status: status,
    direction: direction,
  );
}
