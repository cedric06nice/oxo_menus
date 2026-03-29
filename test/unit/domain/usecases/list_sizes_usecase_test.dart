import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/size.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/domain/usecases/list_sizes_usecase.dart';

class MockSizeRepository extends Mock implements SizeRepository {}

void main() {
  late ListSizesUseCase useCase;
  late MockSizeRepository mockSizeRepository;

  setUp(() {
    mockSizeRepository = MockSizeRepository();
    useCase = ListSizesUseCase(sizeRepository: mockSizeRepository);
  });

  const publishedSize = Size(
    id: 1,
    name: 'A4',
    width: 210,
    height: 297,
    status: Status.published,
    direction: 'portrait',
  );

  const draftSize = Size(
    id: 2,
    name: 'Letter',
    width: 215.9,
    height: 279.4,
    status: Status.draft,
    direction: 'landscape',
  );

  group('ListSizesUseCase', () {
    test('should return all sizes when no filter is provided', () async {
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Success([publishedSize, draftSize]));

      final result = await useCase.execute();

      expect(result.isSuccess, true);
      expect(result.valueOrNull, hasLength(2));
      verify(() => mockSizeRepository.getAll()).called(1);
    });

    test('should return all sizes when filter is "all"', () async {
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Success([publishedSize, draftSize]));

      final result = await useCase.execute(statusFilter: 'all');

      expect(result.isSuccess, true);
      expect(result.valueOrNull, hasLength(2));
    });

    test('should filter sizes by status name', () async {
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Success([publishedSize, draftSize]));

      final result = await useCase.execute(statusFilter: 'published');

      expect(result.isSuccess, true);
      expect(result.valueOrNull, hasLength(1));
      expect(result.valueOrNull!.first.name, 'A4');
    });

    test('should return empty list when no sizes match filter', () async {
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Success([publishedSize]));

      final result = await useCase.execute(statusFilter: 'draft');

      expect(result.isSuccess, true);
      expect(result.valueOrNull, isEmpty);
    });

    test('should return failure when repository fails', () async {
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) async => const Failure(ServerError('Server error')));

      final result = await useCase.execute();

      expect(result.isFailure, true);
      expect(result.errorOrNull, isA<ServerError>());
    });
  });
}
