import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_bundle.dart';
import 'package:oxo_menus/domain/repositories/menu_bundle_repository.dart';
import 'package:oxo_menus/domain/usecases/publish_bundles_for_menu_usecase.dart';
import 'package:oxo_menus/domain/usecases/publish_menu_bundle_usecase.dart';

class MockMenuBundleRepository extends Mock implements MenuBundleRepository {}

class MockPublishMenuBundleUseCase extends Mock
    implements PublishMenuBundleUseCase {}

void main() {
  late MockMenuBundleRepository repo;
  late MockPublishMenuBundleUseCase publishOne;
  late PublishBundlesForMenuUseCase useCase;

  setUp(() {
    repo = MockMenuBundleRepository();
    publishOne = MockPublishMenuBundleUseCase();
    useCase = PublishBundlesForMenuUseCase(
      repository: repo,
      publishMenuBundleUseCase: publishOne,
    );
  });

  group('PublishBundlesForMenuUseCase', () {
    test('publishes every bundle that includes the given menu id', () async {
      const b1 = MenuBundle(id: 1, name: 'A', menuIds: [10]);
      const b2 = MenuBundle(id: 2, name: 'B', menuIds: [10, 20]);
      when(
        () => repo.findByIncludedMenu(10),
      ).thenAnswer((_) async => const Success([b1, b2]));
      when(
        () => publishOne.execute(1),
      ).thenAnswer((_) async => const Success(b1));
      when(
        () => publishOne.execute(2),
      ).thenAnswer((_) async => const Success(b2));

      final results = await useCase.execute(10);

      expect(results, hasLength(2));
      expect(results.every((r) => r.isSuccess), true);
      verify(() => publishOne.execute(1)).called(1);
      verify(() => publishOne.execute(2)).called(1);
    });

    test('returns an empty list when no bundles include the menu', () async {
      when(
        () => repo.findByIncludedMenu(10),
      ).thenAnswer((_) async => const Success([]));

      final results = await useCase.execute(10);

      expect(results, isEmpty);
      verifyNever(() => publishOne.execute(any()));
    });

    test(
      'surfaces repository lookup failure as a single aggregated failure result',
      () async {
        when(() => repo.findByIncludedMenu(10)).thenAnswer(
          (_) async => const Failure<List<MenuBundle>, DomainError>(
            ServerError('lookup failed'),
          ),
        );

        final results = await useCase.execute(10);

        expect(results, hasLength(1));
        expect(results.single.isFailure, true);
        expect(results.single.errorOrNull, isA<ServerError>());
        verifyNever(() => publishOne.execute(any()));
      },
    );

    test('continues publishing other bundles when one publish fails', () async {
      const b1 = MenuBundle(id: 1, name: 'A', menuIds: [10]);
      const b2 = MenuBundle(id: 2, name: 'B', menuIds: [10]);
      when(
        () => repo.findByIncludedMenu(10),
      ).thenAnswer((_) async => const Success([b1, b2]));
      when(() => publishOne.execute(1)).thenAnswer(
        (_) async =>
            const Failure<MenuBundle, DomainError>(ServerError('boom')),
      );
      when(
        () => publishOne.execute(2),
      ).thenAnswer((_) async => const Success(b2));

      final results = await useCase.execute(10);

      expect(results, hasLength(2));
      expect(results[0].isFailure, true);
      expect(results[1].isSuccess, true);
      verify(() => publishOne.execute(1)).called(1);
      verify(() => publishOne.execute(2)).called(1);
    });
  });
}
