import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

part 'admin_templates_state.freezed.dart';

/// State for admin templates list page
@freezed
abstract class AdminTemplatesState with _$AdminTemplatesState {
  const factory AdminTemplatesState({
    @Default([]) List<Menu> templates,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default('all')
    String statusFilter, // 'all', 'draft', 'published', 'archived'
  }) = _AdminTemplatesState;
}
