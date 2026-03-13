import 'dart:async';

import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';

class EditorStyleHelper {
  final ContainerRepository containerRepository;
  final ColumnRepository columnRepository;
  final Map<int, List<entity.Container>> containers;
  final Map<int, List<entity.Column>> columns;
  final VoidCallback onLocalStateChanged;
  final bool Function() isMounted;

  Timer? _styleDebounceTimer;

  EditorStyleHelper({
    required this.containerRepository,
    required this.columnRepository,
    required this.containers,
    required this.columns,
    required this.onLocalStateChanged,
    required this.isMounted,
  });

  void updateContainerStyleLocally(int containerId, StyleConfig newStyle) {
    for (final entry in containers.entries) {
      final idx = entry.value.indexWhere((c) => c.id == containerId);
      if (idx != -1) {
        entry.value[idx] = entry.value[idx].copyWith(styleConfig: newStyle);
        onLocalStateChanged();
        break;
      }
    }
  }

  Future<void> saveContainerStyleToApi(
    int containerId,
    StyleConfig newStyle,
  ) async {
    await containerRepository.update(
      UpdateContainerInput(id: containerId, styleConfig: newStyle),
    );
  }

  Future<void> onContainerStyleChanged(
    int containerId,
    StyleConfig newStyle,
  ) async {
    await saveContainerStyleToApi(containerId, newStyle);
    updateContainerStyleLocally(containerId, newStyle);
  }

  void updateColumnStyleLocally(int columnId, StyleConfig newStyle) {
    for (final entry in columns.entries) {
      final idx = entry.value.indexWhere((c) => c.id == columnId);
      if (idx != -1) {
        entry.value[idx] = entry.value[idx].copyWith(styleConfig: newStyle);
        onLocalStateChanged();
        break;
      }
    }
  }

  Future<void> saveColumnStyleToApi(int columnId, StyleConfig newStyle) async {
    await columnRepository.update(
      UpdateColumnInput(id: columnId, styleConfig: newStyle),
    );
  }

  Future<void> onColumnStyleChanged(int columnId, StyleConfig newStyle) async {
    await saveColumnStyleToApi(columnId, newStyle);
    updateColumnStyleLocally(columnId, newStyle);
  }

  void debounceStyleSave(Future<void> Function() apiCall) {
    _styleDebounceTimer?.cancel();
    _styleDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (isMounted()) {
        apiCall();
      }
    });
  }

  void flushStyleDebounce() {
    _styleDebounceTimer?.cancel();
    _styleDebounceTimer = null;
  }

  void dispose() {
    _styleDebounceTimer?.cancel();
  }
}

typedef VoidCallback = void Function();
