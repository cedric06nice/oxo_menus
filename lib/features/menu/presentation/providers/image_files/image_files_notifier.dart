import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/presentation/providers/image_files/image_files_state.dart';
import 'package:oxo_menus/shared/presentation/providers/usecases_provider.dart';

class ImageFilesNotifier extends Notifier<ImageFilesState> {
  @override
  ImageFilesState build() => const ImageFilesState();

  Future<void> loadImageFiles() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await ref.read(listImageFilesUseCaseProvider).execute();
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
