import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/features/editor_tree/presentation/widgets/editor_tree_loader.dart';

final editorTreeLoaderProvider = Provider<EditorTreeLoader>((ref) {
  return EditorTreeLoader(
    menuRepository: ref.watch(menuRepositoryProvider),
    pageRepository: ref.watch(pageRepositoryProvider),
    containerRepository: ref.watch(containerRepositoryProvider),
    columnRepository: ref.watch(columnRepositoryProvider),
    widgetRepository: ref.watch(widgetRepositoryProvider),
  );
});
