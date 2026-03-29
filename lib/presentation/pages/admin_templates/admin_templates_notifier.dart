import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

/// Notifier for managing admin templates list state
class AdminTemplatesNotifier extends Notifier<AdminTemplatesState> {
  @override
  AdminTemplatesState build() => const AdminTemplatesState();

  /// Load templates from repository with optional status filter
  Future<void> loadTemplates({String? statusFilter}) async {
    final effectiveFilter = statusFilter ?? state.statusFilter;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      statusFilter: effectiveFilter,
    );

    final result = await ref
        .read(listTemplatesUseCaseProvider)
        .execute(statusFilter: effectiveFilter);

    result.fold(
      onSuccess: (templates) {
        state = state.copyWith(templates: templates, isLoading: false);
      },
      onFailure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }

  /// Delete a template by ID
  Future<void> deleteTemplate(int templateId) async {
    final result = await ref.read(menuRepositoryProvider).delete(templateId);

    result.fold(
      onSuccess: (_) {
        // Remove from local state
        state = state.copyWith(
          templates: state.templates.where((t) => t.id != templateId).toList(),
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
