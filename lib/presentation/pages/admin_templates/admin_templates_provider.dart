import 'package:flutter_riverpod/legacy.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

/// Provider for admin templates page state
final adminTemplatesProvider =
    StateNotifierProvider<AdminTemplatesNotifier, AdminTemplatesState>((ref) {
      return AdminTemplatesNotifier(ref.watch(menuRepositoryProvider));
    });
