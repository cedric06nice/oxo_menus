import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/admin_sizes_notifier.dart';
import 'package:oxo_menus/features/admin_sizes/presentation/admin_sizes_state.dart';

/// Provider for admin sizes page state
final adminSizesProvider =
    NotifierProvider<AdminSizesNotifier, AdminSizesState>(
      AdminSizesNotifier.new,
    );
