import 'package:flutter_riverpod/legacy.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_sizes/admin_sizes_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

/// Provider for admin sizes page state
final adminSizesProvider =
    StateNotifierProvider<AdminSizesNotifier, AdminSizesState>((ref) {
      return AdminSizesNotifier(ref.watch(sizeRepositoryProvider));
    });
