import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/features/menu/presentation/providers/image_files/image_files_notifier.dart';
import 'package:oxo_menus/features/menu/presentation/providers/image_files/image_files_state.dart';

final imageFilesProvider =
    NotifierProvider<ImageFilesNotifier, ImageFilesState>(
      ImageFilesNotifier.new,
    );
