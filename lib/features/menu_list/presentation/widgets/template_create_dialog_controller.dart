import 'package:flutter/foundation.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/repositories/area_repository.dart';

/// Immutable state exposed by [TemplateCreateDialogController].
@immutable
class TemplateCreateDialogState {
  const TemplateCreateDialogState({
    this.sizes = const <Size>[],
    this.areas = const <Area>[],
    this.isLoadingSizes = false,
    this.isLoadingAreas = false,
    this.errorMessage,
  });

  final List<Size> sizes;
  final List<Area> areas;
  final bool isLoadingSizes;
  final bool isLoadingAreas;
  final String? errorMessage;

  TemplateCreateDialogState copyWith({
    List<Size>? sizes,
    List<Area>? areas,
    bool? isLoadingSizes,
    bool? isLoadingAreas,
    Object? errorMessage = _sentinel,
  }) {
    return TemplateCreateDialogState(
      sizes: sizes ?? this.sizes,
      areas: areas ?? this.areas,
      isLoadingSizes: isLoadingSizes ?? this.isLoadingSizes,
      isLoadingAreas: isLoadingAreas ?? this.isLoadingAreas,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const Object _sentinel = Object();
}

/// Local controller for the template-create dialog.
///
/// Loads sizes and areas through the injected repositories so the dialog can
/// render dropdowns without going through Riverpod. Replaces the old
/// `menuSettingsProvider` notifier in Phase 28.
class TemplateCreateDialogController extends ChangeNotifier {
  TemplateCreateDialogController({
    required SizeRepository sizeRepository,
    required AreaRepository areaRepository,
  }) : _sizeRepository = sizeRepository,
       _areaRepository = areaRepository;

  final SizeRepository _sizeRepository;
  final AreaRepository _areaRepository;

  TemplateCreateDialogState _state = const TemplateCreateDialogState();
  bool _disposed = false;

  TemplateCreateDialogState get state => _state;

  Future<void> loadSizes() async {
    if (_disposed) {
      return;
    }
    _emit(_state.copyWith(isLoadingSizes: true, errorMessage: null));
    final result = await _sizeRepository.getAll();
    if (_disposed) {
      return;
    }
    result.fold(
      onSuccess: (sizes) =>
          _emit(_state.copyWith(sizes: sizes, isLoadingSizes: false)),
      onFailure: (error) => _emit(
        _state.copyWith(isLoadingSizes: false, errorMessage: error.message),
      ),
    );
  }

  Future<void> loadAreas() async {
    if (_disposed) {
      return;
    }
    _emit(_state.copyWith(isLoadingAreas: true, errorMessage: null));
    final result = await _areaRepository.getAll();
    if (_disposed) {
      return;
    }
    result.fold(
      onSuccess: (areas) =>
          _emit(_state.copyWith(areas: areas, isLoadingAreas: false)),
      onFailure: (error) => _emit(
        _state.copyWith(isLoadingAreas: false, errorMessage: error.message),
      ),
    );
  }

  void _emit(TemplateCreateDialogState next) {
    if (_disposed) {
      return;
    }
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    super.dispose();
  }
}
