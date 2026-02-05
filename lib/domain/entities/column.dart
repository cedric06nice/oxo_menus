import 'package:freezed_annotation/freezed_annotation.dart';

part 'column.freezed.dart';
part 'column.g.dart';

/// Represents a column within a container.
@freezed
abstract class Column with _$Column {
  const Column._();

  const factory Column({
    required int id,
    required int containerId,
    required int index,
    int? flex,
    double? width,
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) = _Column;

  factory Column.fromJson(Map<String, dynamic> json) => _$ColumnFromJson(json);
}
