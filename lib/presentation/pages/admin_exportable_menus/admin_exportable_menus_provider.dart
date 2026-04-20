import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/presentation/pages/admin_exportable_menus/admin_exportable_menus_notifier.dart';
import 'package:oxo_menus/presentation/pages/admin_exportable_menus/admin_exportable_menus_state.dart';

final adminExportableMenusProvider =
    NotifierProvider<AdminExportableMenusNotifier, AdminExportableMenusState>(
      AdminExportableMenusNotifier.new,
    );
