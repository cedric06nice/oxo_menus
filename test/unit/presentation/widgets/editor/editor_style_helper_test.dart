import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/column.dart' as entity;
import 'package:oxo_menus/domain/entities/container.dart' as entity;
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/repositories/column_repository.dart';
import 'package:oxo_menus/domain/repositories/container_repository.dart';
import 'package:oxo_menus/presentation/widgets/editor/editor_style_helper.dart';

class MockContainerRepository extends Mock implements ContainerRepository {}

class MockColumnRepository extends Mock implements ColumnRepository {}

class FakeUpdateContainerInput extends Fake implements UpdateContainerInput {}

class FakeUpdateColumnInput extends Fake implements UpdateColumnInput {}

void main() {
  late MockContainerRepository mockContainerRepo;
  late MockColumnRepository mockColumnRepo;
  late EditorStyleHelper helper;
  late Map<int, List<entity.Container>> containers;
  late Map<int, List<entity.Column>> columns;
  late int setStateCalls;

  setUpAll(() {
    registerFallbackValue(FakeUpdateContainerInput());
    registerFallbackValue(FakeUpdateColumnInput());
  });

  setUp(() {
    mockContainerRepo = MockContainerRepository();
    mockColumnRepo = MockColumnRepository();
    containers = {
      1: [const entity.Container(id: 10, pageId: 1, index: 0)],
    };
    columns = {
      10: [const entity.Column(id: 20, containerId: 10, index: 0, flex: 1)],
    };
    setStateCalls = 0;

    helper = EditorStyleHelper(
      containerRepository: mockContainerRepo,
      columnRepository: mockColumnRepo,
      containers: containers,
      columns: columns,
      onLocalStateChanged: () => setStateCalls++,
      isMounted: () => true,
    );
  });

  group('onContainerStyleChanged', () {
    test('saves to API and updates local state', () async {
      when(
        () => mockContainerRepo.update(any()),
      ).thenAnswer((_) async => Success(containers[1]!.first));

      const style = StyleConfig(paddingTop: 10);
      await helper.onContainerStyleChanged(10, style);

      verify(() => mockContainerRepo.update(any())).called(1);
      expect(setStateCalls, 1);
      expect(containers[1]!.first.styleConfig, style);
    });
  });

  group('onColumnStyleChanged', () {
    test('saves to API and updates local state', () async {
      when(
        () => mockColumnRepo.update(any()),
      ).thenAnswer((_) async => Success(columns[10]!.first));

      const style = StyleConfig(paddingLeft: 5);
      await helper.onColumnStyleChanged(20, style);

      verify(() => mockColumnRepo.update(any())).called(1);
      expect(setStateCalls, 1);
      expect(columns[10]!.first.styleConfig, style);
    });
  });

  group('updateContainerStyleLocally', () {
    test('updates style in containers map', () {
      const style = StyleConfig(marginTop: 8);
      helper.updateContainerStyleLocally(10, style);

      expect(containers[1]!.first.styleConfig, style);
      expect(setStateCalls, 1);
    });
  });

  group('updateColumnStyleLocally', () {
    test('updates style in columns map', () {
      const style = StyleConfig(marginLeft: 3);
      helper.updateColumnStyleLocally(20, style);

      expect(columns[10]!.first.styleConfig, style);
      expect(setStateCalls, 1);
    });
  });

  group('debounceStyleSave', () {
    test('delays API call by 500ms', () {
      fakeAsync((async) {
        var called = false;
        helper.debounceStyleSave(() async => called = true);

        async.elapse(const Duration(milliseconds: 400));
        expect(called, isFalse);

        async.elapse(const Duration(milliseconds: 100));
        expect(called, isTrue);
      });
    });

    test('cancels previous call when called again', () {
      fakeAsync((async) {
        var callCount = 0;
        helper.debounceStyleSave(() async => callCount++);
        async.elapse(const Duration(milliseconds: 300));
        helper.debounceStyleSave(() async => callCount++);
        async.elapse(const Duration(milliseconds: 500));
        expect(callCount, 1);
      });
    });
  });

  group('flushStyleDebounce', () {
    test('cancels pending debounce', () {
      fakeAsync((async) {
        var called = false;
        helper.debounceStyleSave(() async => called = true);
        helper.flushStyleDebounce();
        async.elapse(const Duration(milliseconds: 600));
        expect(called, isFalse);
      });
    });
  });

  group('dispose', () {
    test('cancels debounce timer', () {
      fakeAsync((async) {
        var called = false;
        helper.debounceStyleSave(() async => called = true);
        helper.dispose();
        async.elapse(const Duration(milliseconds: 600));
        expect(called, isFalse);
      });
    });
  });
}
