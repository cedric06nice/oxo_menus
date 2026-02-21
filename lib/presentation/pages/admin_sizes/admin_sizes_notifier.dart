import 'package:flutter_riverpod/legacy.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_state.dart';

/// Notifier for managing admin sizes list state
class AdminSizesNotifier extends StateNotifier<AdminSizesState> {
  final SizeRepository _sizeRepository;

  AdminSizesNotifier(this._sizeRepository) : super(const AdminSizesState());

  /// Load sizes from repository with optional status filter
  Future<void> loadSizes({String? statusFilter}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      statusFilter: statusFilter ?? state.statusFilter,
    );

    final result = await _sizeRepository.getAll();

    result.fold(
      onSuccess: (sizes) {
        var filtered = sizes;

        if (state.statusFilter != 'all') {
          filtered = sizes
              .where((s) => s.status.name == state.statusFilter)
              .toList();
        }

        state = state.copyWith(sizes: filtered, isLoading: false);
      },
      onFailure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }

  /// Create a new size
  Future<void> createSize(CreateSizeInput input) async {
    final result = await _sizeRepository.create(input);

    result.fold(
      onSuccess: (size) {
        state = state.copyWith(sizes: [...state.sizes, size]);
      },
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
      },
    );
  }

  /// Update an existing size
  Future<void> updateSize(UpdateSizeInput input) async {
    final result = await _sizeRepository.update(input);

    result.fold(
      onSuccess: (updatedSize) {
        state = state.copyWith(
          sizes: state.sizes
              .map((s) => s.id == updatedSize.id ? updatedSize : s)
              .toList(),
        );
      },
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
      },
    );
  }

  /// Delete a size by ID
  Future<void> deleteSize(int id) async {
    final result = await _sizeRepository.delete(id);

    result.fold(
      onSuccess: (_) {
        state = state.copyWith(
          sizes: state.sizes.where((s) => s.id != id).toList(),
        );
      },
      onFailure: (error) {
        state = state.copyWith(errorMessage: error.message);
      },
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
