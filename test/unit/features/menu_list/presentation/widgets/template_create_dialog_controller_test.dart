import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/features/menu_list/presentation/widgets/template_create_dialog_controller.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

import '../../../../../fakes/fake_area_repository.dart';
import '../../../../../fakes/fake_size_repository.dart';
import '../../../../../fakes/reflectable_bootstrap.dart';

void main() {
  setUpAll(initializeReflectableForTests);

  group('TemplateCreateDialogController', () {
    late FakeSizeRepository sizeRepo;
    late FakeAreaRepository areaRepo;

    setUp(() {
      sizeRepo = FakeSizeRepository();
      areaRepo = FakeAreaRepository();
    });

    test('starts with empty state', () {
      final controller = TemplateCreateDialogController(
        sizeRepository: sizeRepo,
        areaRepository: areaRepo,
      );
      addTearDown(controller.dispose);

      expect(controller.state.sizes, isEmpty);
      expect(controller.state.areas, isEmpty);
      expect(controller.state.isLoadingSizes, isFalse);
      expect(controller.state.isLoadingAreas, isFalse);
      expect(controller.state.errorMessage, isNull);
    });

    test('loadSizes populates state and notifies listeners', () async {
      const size = Size(
        id: 1,
        name: 'A4',
        width: 210,
        height: 297,
        status: Status.published,
        direction: 'portrait',
      );
      sizeRepo.whenGetAll(Success<List<Size>, DomainError>([size]));
      final controller = TemplateCreateDialogController(
        sizeRepository: sizeRepo,
        areaRepository: areaRepo,
      );
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.loadSizes();

      expect(controller.state.sizes, [size]);
      expect(controller.state.isLoadingSizes, isFalse);
      expect(notifications, greaterThanOrEqualTo(2));
    });

    test('loadSizes records error when repository fails', () async {
      sizeRepo.whenGetAll(
        const Failure<List<Size>, DomainError>(NetworkError('boom')),
      );
      final controller = TemplateCreateDialogController(
        sizeRepository: sizeRepo,
        areaRepository: areaRepo,
      );
      addTearDown(controller.dispose);

      await controller.loadSizes();

      expect(controller.state.sizes, isEmpty);
      expect(controller.state.isLoadingSizes, isFalse);
      expect(controller.state.errorMessage, isNotNull);
    });

    test('loadAreas populates state and notifies listeners', () async {
      const area = Area(id: 1, name: 'Lobby');
      areaRepo.whenGetAll(const Success<List<Area>, DomainError>([area]));
      final controller = TemplateCreateDialogController(
        sizeRepository: sizeRepo,
        areaRepository: areaRepo,
      );
      addTearDown(controller.dispose);

      await controller.loadAreas();

      expect(controller.state.areas, [area]);
      expect(controller.state.isLoadingAreas, isFalse);
    });

    test('loadAreas records error when repository fails', () async {
      areaRepo.whenGetAll(
        const Failure<List<Area>, DomainError>(NetworkError('offline')),
      );
      final controller = TemplateCreateDialogController(
        sizeRepository: sizeRepo,
        areaRepository: areaRepo,
      );
      addTearDown(controller.dispose);

      await controller.loadAreas();

      expect(controller.state.areas, isEmpty);
      expect(controller.state.errorMessage, isNotNull);
    });

    test('does not notify after dispose', () async {
      sizeRepo.whenGetAll(const Success<List<Size>, DomainError>([]));
      final controller = TemplateCreateDialogController(
        sizeRepository: sizeRepo,
        areaRepository: areaRepo,
      );

      var notifications = 0;
      controller.addListener(() => notifications++);
      controller.dispose();

      await controller.loadSizes();

      expect(notifications, 0);
    });

    test('disposing twice is safe', () {
      final controller = TemplateCreateDialogController(
        sizeRepository: sizeRepo,
        areaRepository: areaRepo,
      );

      controller.dispose();

      expect(controller.dispose, returnsNormally);
    });
  });
}
