import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/domain/repositories/auth_repository.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/file_repository.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/repositories/widget_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  group('repositories_provider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          directusDataSourceProvider
              .overrideWithValue(MockDirectusDataSource()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('directusBaseUrlProvider should return default URL', () {
      final url = container.read(directusBaseUrlProvider);
      expect(url, 'http://localhost:8055');
    });

    test('menuRepositoryProvider should return MenuRepository', () {
      final repo = container.read(menuRepositoryProvider);
      expect(repo, isA<MenuRepository>());
    });

    test('pageRepositoryProvider should return PageRepository', () {
      final repo = container.read(pageRepositoryProvider);
      expect(repo, isA<PageRepository>());
    });

    test('containerRepositoryProvider should return ContainerRepository', () {
      final repo = container.read(containerRepositoryProvider);
      expect(repo, isA<ContainerRepository>());
    });

    test('columnRepositoryProvider should return ColumnRepository', () {
      final repo = container.read(columnRepositoryProvider);
      expect(repo, isA<ColumnRepository>());
    });

    test('widgetRepositoryProvider should return WidgetRepository', () {
      final repo = container.read(widgetRepositoryProvider);
      expect(repo, isA<WidgetRepository>());
    });

    test('authRepositoryProvider should return AuthRepository', () {
      final repo = container.read(authRepositoryProvider);
      expect(repo, isA<AuthRepository>());
    });

    test('sizeRepositoryProvider should return SizeRepository', () {
      final repo = container.read(sizeRepositoryProvider);
      expect(repo, isA<SizeRepository>());
    });

    test('fileRepositoryProvider should return FileRepository', () {
      final repo = container.read(fileRepositoryProvider);
      expect(repo, isA<FileRepository>());
    });
  });
}
