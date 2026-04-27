import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/repositories/size_repository.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/admin_sizes_state.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/shared/presentation/providers/usecases_provider.dart';

/// Notifier for managing admin sizes list state
class AdminSizesNotifier extends Notifier<AdminSizesState> {
  @override
  AdminSizesState build() => const AdminSizesState();

  /// Load sizes from repository with optional status filter
  Future<void> loadSizes({String? statusFilter}) async {
    final effectiveFilter = statusFilter ?? state.statusFilter;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      statusFilter: effectiveFilter,
    );

    final result = await ref
        .read(listSizesUseCaseProvider)
        .execute(statusFilter: effectiveFilter);

    result.fold(
      onSuccess: (sizes) {
        state = state.copyWith(sizes: sizes, isLoading: false);
      },
      onFailure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }

  /// Create a new size
  Future<void> createSize(CreateSizeInput input) async {
    final result = await ref.read(sizeRepositoryProvider).create(input);

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
    final result = await ref.read(sizeRepositoryProvider).update(input);

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
    final result = await ref.read(sizeRepositoryProvider).delete(id);

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
