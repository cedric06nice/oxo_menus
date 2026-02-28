import 'package:flutter_riverpod/legacy.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_state.dart';
import 'package:oxo_menus/core/types/result.dart';

/// Notifier for managing admin templates list state
class AdminTemplatesNotifier extends StateNotifier<AdminTemplatesState> {
  final MenuRepository _menuRepository;

  AdminTemplatesNotifier(this._menuRepository)
    : super(const AdminTemplatesState());

  /// Load templates from repository with optional status filter
  Future<void> loadTemplates({String? statusFilter}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      statusFilter: statusFilter ?? state.statusFilter,
    );

    // Fetch all menus (not just published)
    final result = await _menuRepository.listAll(onlyPublished: false);

    result.fold(
      onSuccess: (menus) {
        // Filter templates based on status filter
        var templates = menus;

        // Apply status filter if not 'all'
        if (state.statusFilter != 'all') {
          templates = templates
              .where((m) => m.status.name == state.statusFilter)
              .toList();
        }

        state = state.copyWith(templates: templates, isLoading: false);
      },
      onFailure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }

  /// Delete a template by ID
  Future<void> deleteTemplate(int templateId) async {
    final result = await _menuRepository.delete(templateId);

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
