import 'package:freezed_annotation/freezed_annotation.dart';

part 'area.freezed.dart';
part 'area.g.dart';

/// Represents a restaurant area (e.g., Dining, Bar, Terrace).
@freezed
abstract class Area with _$Area {
  const Area._();

  const factory Area({required int id, required String name}) = _Area;

  factory Area.fromJson(Map<String, dynamic> json) => _$AreaFromJson(json);
}
