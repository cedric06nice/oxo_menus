import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxo_menus/domain/entities/size.dart';

part 'admin_sizes_state.freezed.dart';

/// State for admin sizes list page
@freezed
abstract class AdminSizesState with _$AdminSizesState {
  const factory AdminSizesState({
    @Default([]) List<Size> sizes,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default('all')
    String statusFilter, // 'all', 'draft', 'published', 'archived'
  }) = _AdminSizesState;
}
