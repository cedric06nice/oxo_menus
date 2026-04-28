import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/admin_template_creator/presentation/state/admin_template_creator_screen_state.dart';
import 'package:oxo_menus/features/menu/domain/entities/size.dart';
import 'package:oxo_menus/shared/domain/entities/area.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';

const _size = Size(
  id: 1,
  name: 'A4',
  width: 210,
  height: 297,
  status: Status.published,
  direction: 'portrait',
);

const _area = Area(id: 1, name: 'Dining');

void main() {
  group('AdminTemplateCreatorScreenState — defaults', () {
    test('default state matches the pre-load snapshot', () {
      const state = AdminTemplateCreatorScreenState();

      expect(state.isAdmin, isFalse);
      expect(state.isLoadingSizes, isTrue);
      expect(state.isLoadingAreas, isTrue);
      expect(state.errorMessage, isNull);
      expect(state.sizes, isEmpty);
      expect(state.areas, isEmpty);
      expect(state.selectedSize, isNull);
      expect(state.selectedArea, isNull);
      expect(state.isSaving, isFalse);
    });
  });

  group('AdminTemplateCreatorScreenState — equality', () {
    test('two equal states compare equal and share a hashCode', () {
      const a = AdminTemplateCreatorScreenState(
        isAdmin: true,
        isLoadingSizes: false,
        sizes: [_size],
        selectedSize: _size,
        areas: [_area],
        selectedArea: _area,
      );
      const b = AdminTemplateCreatorScreenState(
        isAdmin: true,
        isLoadingSizes: false,
        sizes: [_size],
        selectedSize: _size,
        areas: [_area],
        selectedArea: _area,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('changing each scalar field breaks equality', () {
      const base = AdminTemplateCreatorScreenState();

      expect(base, isNot(base.copyWith(isAdmin: true)));
      expect(base, isNot(base.copyWith(isLoadingSizes: false)));
      expect(base, isNot(base.copyWith(isLoadingAreas: false)));
      expect(base, isNot(base.copyWith(isSaving: true)));
      expect(base, isNot(base.copyWith(errorMessage: 'oops')));
      expect(base, isNot(base.copyWith(selectedSize: _size)));
      expect(base, isNot(base.copyWith(selectedArea: _area)));
    });

    test('list equality compares element-by-element', () {
      const a = AdminTemplateCreatorScreenState(sizes: [_size]);
      const b = AdminTemplateCreatorScreenState(sizes: [_size]);
      const c = AdminTemplateCreatorScreenState(sizes: <Size>[]);

      expect(a, b);
      expect(a, isNot(c));

      const d = AdminTemplateCreatorScreenState(areas: [_area]);
      const e = AdminTemplateCreatorScreenState(areas: [_area]);
      const f = AdminTemplateCreatorScreenState(areas: <Area>[]);

      expect(d, e);
      expect(d, isNot(f));
    });
  });

  group('AdminTemplateCreatorScreenState — copyWith', () {
    test('returns identical state when no overrides are passed', () {
      const state = AdminTemplateCreatorScreenState(
        isAdmin: true,
        sizes: [_size],
        selectedSize: _size,
        errorMessage: 'oops',
      );

      expect(state.copyWith(), state);
    });

    test('null sentinel — explicit null clears errorMessage', () {
      const base = AdminTemplateCreatorScreenState(errorMessage: 'oops');

      expect(base.copyWith(errorMessage: null).errorMessage, isNull);
    });

    test('null sentinel — explicit null clears selectedSize', () {
      const base = AdminTemplateCreatorScreenState(selectedSize: _size);

      expect(base.copyWith(selectedSize: null).selectedSize, isNull);
    });

    test('null sentinel — explicit null clears selectedArea', () {
      const base = AdminTemplateCreatorScreenState(selectedArea: _area);

      expect(base.copyWith(selectedArea: null).selectedArea, isNull);
    });

    test('omitting nullable fields preserves the previous values', () {
      const base = AdminTemplateCreatorScreenState(
        errorMessage: 'oops',
        selectedSize: _size,
        selectedArea: _area,
      );

      final copy = base.copyWith(isSaving: true);

      expect(copy.errorMessage, 'oops');
      expect(copy.selectedSize, _size);
      expect(copy.selectedArea, _area);
      expect(copy.isSaving, isTrue);
    });
  });
}
