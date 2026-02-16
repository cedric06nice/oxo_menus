import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/domain/usecases/duplicate_menu_usecase.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/generate_pdf_usecase.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/providers/usecases_provider.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class MockWidgetRepository extends Mock implements WidgetRepository {}

class MockSizeRepository extends Mock implements SizeRepository {}

class MockFileRepository extends Mock implements FileRepository {}

void main() {
  group('usecases_provider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          menuRepositoryProvider.overrideWithValue(MockMenuRepository()),
          pageRepositoryProvider.overrideWithValue(MockPageRepository()),
          containerRepositoryProvider
              .overrideWithValue(MockContainerRepository()),
          columnRepositoryProvider.overrideWithValue(MockColumnRepository()),
          widgetRepositoryProvider.overrideWithValue(MockWidgetRepository()),
          sizeRepositoryProvider.overrideWithValue(MockSizeRepository()),
          fileRepositoryProvider.overrideWithValue(MockFileRepository()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('fetchMenuTreeUseCaseProvider should return FetchMenuTreeUseCase', () {
      final useCase = container.read(fetchMenuTreeUseCaseProvider);
      expect(useCase, isA<FetchMenuTreeUseCase>());
    });

    test('generatePdfUseCaseProvider should return GeneratePdfUseCase', () {
      final useCase = container.read(generatePdfUseCaseProvider);
      expect(useCase, isA<GeneratePdfUseCase>());
    });

    test('duplicateMenuUseCaseProvider should return DuplicateMenuUseCase',
        () {
      final useCase = container.read(duplicateMenuUseCaseProvider);
      expect(useCase, isA<DuplicateMenuUseCase>());
    });
  });
}
