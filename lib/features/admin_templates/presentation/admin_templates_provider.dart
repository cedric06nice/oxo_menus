import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/features/admin_templates/presentation/admin_templates_notifier.dart';
import 'package:oxo_menus/features/admin_templates/presentation/admin_templates_state.dart';

/// Provider for admin templates page state
final adminTemplatesProvider =
    NotifierProvider<AdminTemplatesNotifier, AdminTemplatesState>(
      AdminTemplatesNotifier.new,
    );
