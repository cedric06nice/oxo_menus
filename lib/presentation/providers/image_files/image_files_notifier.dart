import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/presentation/providers/image_files/image_files_state.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class ImageFilesNotifier extends Notifier<ImageFilesState> {
  @override
  ImageFilesState build() => const ImageFilesState();

  Future<void> loadImageFiles() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await ref.read(fileRepositoryProvider).listImageFiles();
    result.fold(
      onSuccess: (files) {
        state = state.copyWith(files: files, isLoading: false);
      },
      onFailure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }
}
