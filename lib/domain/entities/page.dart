import 'package:freezed_annotation/freezed_annotation.dart';

part 'page.freezed.dart';
part 'page.g.dart';

/// Represents a page within a menu.
@freezed
abstract class Page with _$Page {
  const Page._();

  const factory Page({
    required int id,
    required int menuId,
    required String name,
    required int index,
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) = _Page;

  factory Page.fromJson(Map<String, dynamic> json) => _$PageFromJson(json);
}
