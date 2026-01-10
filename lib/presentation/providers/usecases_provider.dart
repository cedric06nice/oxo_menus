import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

/// Fetch menu tree use case provider
///
/// Provides the FetchMenuTreeUseCase for loading complete menu hierarchies
/// with all pages, containers, columns, and widgets.
///
/// Example usage:
/// ```dart
/// final useCase = ref.read(fetchMenuTreeUseCaseProvider);
/// final result = await useCase.execute(menuId);
/// result.fold(
///   onSuccess: (menuTree) => print('Loaded menu: ${menuTree.menu.name}'),
///   onFailure: (error) => print('Error: ${error.message}'),
/// );
/// ```
final fetchMenuTreeUseCaseProvider = Provider<FetchMenuTreeUseCase>((ref) {
  return FetchMenuTreeUseCase(
    menuRepository: ref.watch(menuRepositoryProvider),
    pageRepository: ref.watch(pageRepositoryProvider),
    containerRepository: ref.watch(containerRepositoryProvider),
    columnRepository: ref.watch(columnRepositoryProvider),
    widgetRepository: ref.watch(widgetRepositoryProvider),
  );
});
