import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/menu_repository.dart';
import 'package:oxo_menus/domain/usecases/list_templates_usecase.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late ListTemplatesUseCase useCase;
  late MockMenuRepository mockMenuRepository;

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    useCase = ListTemplatesUseCase(menuRepository: mockMenuRepository);
  });

  const draftMenu = Menu(
    id: 1,
    name: 'Template 1',
    status: Status.draft,
    version: '1.0.0',
  );

  const publishedMenu = Menu(
    id: 2,
    name: 'Template 2',
    status: Status.published,
    version: '1.0.0',
  );

  const archivedMenu = Menu(
    id: 3,
    name: 'Template 3',
    status: Status.archived,
    version: '1.0.0',
  );

  final allMenus = [draftMenu, publishedMenu, archivedMenu];

  group('ListTemplatesUseCase', () {
    test('should fetch all menus with onlyPublished false', () async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(allMenus));

      await useCase.execute();

      verify(() => mockMenuRepository.listAll(onlyPublished: false)).called(1);
    });

    test('should return all templates when no filter is provided', () async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(allMenus));

      final result = await useCase.execute();

      expect(result.isSuccess, true);
      expect(result.valueOrNull, hasLength(3));
    });

    test('should return all templates when filter is "all"', () async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(allMenus));

      final result = await useCase.execute(statusFilter: 'all');

      expect(result.isSuccess, true);
      expect(result.valueOrNull, hasLength(3));
    });

    test('should filter templates by status', () async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => Success(allMenus));

      final result = await useCase.execute(statusFilter: 'draft');

      expect(result.isSuccess, true);
      expect(result.valueOrNull, hasLength(1));
      expect(result.valueOrNull!.first.status, Status.draft);
    });

    test('should return empty list when no templates match filter', () async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => const Success([draftMenu]));

      final result = await useCase.execute(statusFilter: 'published');

      expect(result.isSuccess, true);
      expect(result.valueOrNull, isEmpty);
    });

    test('should return failure when repository fails', () async {
      when(
        () => mockMenuRepository.listAll(onlyPublished: false),
      ).thenAnswer((_) async => const Failure(ServerError('Server error')));

      final result = await useCase.execute();

      expect(result.isFailure, true);
      expect(result.errorOrNull, isA<ServerError>());
    });
  });
}
