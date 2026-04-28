import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_bundle.freezed.dart';
part 'menu_bundle.g.dart';

/// A named bundle of existing menus that can be exported as a single PDF.
///
/// When any included menu is previewed via the PDF button, the bundle PDF is
/// (re)generated and uploaded to Directus. The uploaded file overwrites the
/// same [pdfFileId] so the public URL is stable.
@freezed
abstract class MenuBundle with _$MenuBundle {
  const MenuBundle._();

  const factory MenuBundle({
    required int id,
    required String name,
    @Default([]) List<int> menuIds,
    String? pdfFileId,
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) = _MenuBundle;

  factory MenuBundle.fromJson(Map<String, dynamic> json) =>
      _$MenuBundleFromJson(json);
}
