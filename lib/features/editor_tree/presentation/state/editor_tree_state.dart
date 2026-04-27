import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/features/menu/domain/entities/column.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/container.dart'
    as entity;
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
// ignore: unused_import
import 'package:oxo_menus/features/menu/domain/entities/page.dart';
import 'package:oxo_menus/features/menu/domain/entities/page.dart' as entity;
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';

part 'editor_tree_state.freezed.dart';

@freezed
abstract class EditorTreeState with _$EditorTreeState {
  const factory EditorTreeState({
    Menu? menu,
    @Default([]) List<entity.Page> pages,
    entity.Page? headerPage,
    entity.Page? footerPage,
    @Default({}) Map<int, List<entity.Container>> containers,
    @Default({}) Map<int, List<entity.Container>> childContainers,
    @Default({}) Map<int, List<entity.Column>> columns,
    @Default({}) Map<int, List<WidgetInstance>> widgets,
    @Default(true) bool isLoading,
    String? errorMessage,
    @Default({}) Map<int, int> hoverIndex,
  }) = _EditorTreeState;
}
