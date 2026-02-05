import 'package:freezed_annotation/freezed_annotation.dart';

part 'size.freezed.dart';
part 'size.g.dart';

/// Represents a page size configuration from the database.
@freezed
abstract class Size with _$Size {
  const Size._();

  const factory Size({
    required int id,
    required String name,
    required double width,
    required double height,
  }) = _Size;

  factory Size.fromJson(Map<String, dynamic> json) => _$SizeFromJson(json);
}
