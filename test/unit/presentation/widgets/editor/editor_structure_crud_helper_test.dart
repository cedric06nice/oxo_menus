import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/page.dart' as entity;
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/domain/repositories/page_repository.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_structure_crud_helper.dart';

class MockPageRepository extends Mock implements PageRepository {}

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class FakeCreatePageInput extends Fake implements CreatePageInput {}

class FakeCreateContainerInput extends Fake implements CreateContainerInput {}

class FakeCreateColumnInput extends Fake implements CreateColumnInput {}

void main() {
  late MockPageRepository mockPageRepo;
  late MockContainerRepository mockContainerRepo;
  late MockColumnRepository mockColumnRepo;
  late EditorStructureCrudHelper helper;
  late int reloadCount;
  late List<String> messages;

  setUpAll(() {
    registerFallbackValue(FakeCreatePageInput());
    registerFallbackValue(FakeCreateContainerInput());
    registerFallbackValue(FakeCreateColumnInput());
  });

  setUp(() {
    mockPageRepo = MockPageRepository();
    mockContainerRepo = MockContainerRepository();
    mockColumnRepo = MockColumnRepository();
    reloadCount = 0;
    messages = [];

    helper = EditorStructureCrudHelper(
      pageRepository: mockPageRepo,
      containerRepository: mockContainerRepo,
      columnRepository: mockColumnRepo,
      onReload: () async => reloadCount++,
      onMessage: (msg, {bool isError = false}) =>
          messages.add('${isError ? 'ERROR:' : ''}$msg'),
      showDeleteConfirmation: () async => true,
    );
  });

  final fakePage = entity.Page(id: 1, menuId: 1, name: 'P', index: 0);

  group('addPage', () {
    test('creates page and reloads on success', () async {
      when(
        () => mockPageRepo.create(any()),
      ).thenAnswer((_) async => Success(fakePage));

      await helper.addPage(menuId: 1, pageCount: 2);

      verify(() => mockPageRepo.create(any())).called(1);
      expect(reloadCount, 1);
    });

    test('shows error message on failure', () async {
      when(
        () => mockPageRepo.create(any()),
      ).thenAnswer((_) async => Failure(ServerError('oops')));

      await helper.addPage(menuId: 1, pageCount: 0);

      expect(reloadCount, 0);
      expect(messages, isNotEmpty);
      expect(messages.first, contains('ERROR:'));
    });
  });

  group('deletePage', () {
    test('deletes and reloads on success', () async {
      when(
        () => mockPageRepo.delete(any()),
      ).thenAnswer((_) async => const Success(null));

      await helper.deletePage(42);

      verify(() => mockPageRepo.delete(42)).called(1);
      expect(reloadCount, 1);
    });

    test('does nothing when confirmation declined', () async {
      helper = EditorStructureCrudHelper(
        pageRepository: mockPageRepo,
        containerRepository: mockContainerRepo,
        columnRepository: mockColumnRepo,
        onReload: () async => reloadCount++,
        showDeleteConfirmation: () async => false,
      );

      await helper.deletePage(42);

      verifyNever(() => mockPageRepo.delete(any()));
      expect(reloadCount, 0);
    });
  });

  group('addHeader', () {
    test('creates header page and reloads on success', () async {
      when(
        () => mockPageRepo.create(any()),
      ).thenAnswer((_) async => Success(fakePage));

      await helper.addHeader(1);

      verify(() => mockPageRepo.create(any())).called(1);
      expect(reloadCount, 1);
    });
  });

  group('addFooter', () {
    test('creates footer page and reloads on success', () async {
      when(
        () => mockPageRepo.create(any()),
      ).thenAnswer((_) async => Success(fakePage));

      await helper.addFooter(1);

      verify(() => mockPageRepo.create(any())).called(1);
      expect(reloadCount, 1);
    });
  });

  group('addContainer', () {
    test('creates container and reloads on success', () async {
      final fakeContainer = entity.Container(id: 1, pageId: 1, index: 0);
      when(
        () => mockContainerRepo.create(any()),
      ).thenAnswer((_) async => Success(fakeContainer));

      await helper.addContainer(pageId: 1, containerCount: 0);

      verify(() => mockContainerRepo.create(any())).called(1);
      expect(reloadCount, 1);
    });

    test('shows error message on failure', () async {
      when(
        () => mockContainerRepo.create(any()),
      ).thenAnswer((_) async => Failure(ServerError('fail')));

      await helper.addContainer(pageId: 1, containerCount: 0);

      expect(reloadCount, 0);
      expect(messages, isNotEmpty);
    });
  });

  group('deleteContainer', () {
    test('deletes and reloads on success', () async {
      when(
        () => mockContainerRepo.delete(any()),
      ).thenAnswer((_) async => const Success(null));

      await helper.deleteContainer(5);

      verify(() => mockContainerRepo.delete(5)).called(1);
      expect(reloadCount, 1);
    });
  });

  group('addColumn', () {
    test('creates column and reloads on success', () async {
      final fakeColumn = entity.Column(
        id: 1,
        containerId: 1,
        index: 0,
        flex: 1,
      );
      when(
        () => mockColumnRepo.create(any()),
      ).thenAnswer((_) async => Success(fakeColumn));

      await helper.addColumn(containerId: 1, columnCount: 0);

      verify(() => mockColumnRepo.create(any())).called(1);
      expect(reloadCount, 1);
    });
  });

  group('deleteColumn', () {
    test('deletes and reloads on success', () async {
      when(
        () => mockColumnRepo.delete(any()),
      ).thenAnswer((_) async => const Success(null));

      await helper.deleteColumn(7);

      verify(() => mockColumnRepo.delete(7)).called(1);
      expect(reloadCount, 1);
    });
  });
}
