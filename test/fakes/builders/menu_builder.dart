import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

/// Builds a [Menu] with sensible test defaults.
///
/// Override only the fields relevant to a specific test:
/// ```dart
/// final menu = buildMenu(name: 'Lunch', status: Status.published);
/// ```
Menu buildMenu({
  int id = 1,
  String name = 'Test Menu',
  Status status = Status.draft,
  String version = '1',
  DateTime? dateCreated,
  DateTime? dateUpdated,
  String? userCreated,
  String? userUpdated,
  StyleConfig? styleConfig,
  PageSize? pageSize,
}) {
  return Menu(
    id: id,
    name: name,
    status: status,
    version: version,
    dateCreated: dateCreated,
    dateUpdated: dateUpdated,
    userCreated: userCreated,
    userUpdated: userUpdated,
    styleConfig: styleConfig,
    pageSize: pageSize,
  );
}

/// Builds a [StyleConfig] with all optional fields defaulting to null.
StyleConfig buildStyleConfig({
  String? fontFamily,
  double? fontSize,
  String? primaryColor,
  String? secondaryColor,
  String? backgroundColor,
  double? margin,
  double? marginTop,
  double? marginBottom,
  double? marginLeft,
  double? marginRight,
  double? padding,
  double? paddingTop,
  double? paddingBottom,
  double? paddingLeft,
  double? paddingRight,
}) {
  return StyleConfig(
    fontFamily: fontFamily,
    fontSize: fontSize,
    primaryColor: primaryColor,
    secondaryColor: secondaryColor,
    backgroundColor: backgroundColor,
    margin: margin,
    marginTop: marginTop,
    marginBottom: marginBottom,
    marginLeft: marginLeft,
    marginRight: marginRight,
    padding: padding,
    paddingTop: paddingTop,
    paddingBottom: paddingBottom,
    paddingLeft: paddingLeft,
    paddingRight: paddingRight,
  );
}

/// Builds a [PageSize] with A4-like defaults.
PageSize buildPageSize({
  String name = 'A4',
  double width = 210.0,
  double height = 297.0,
}) {
  return PageSize(name: name, width: width, height: height);
}
