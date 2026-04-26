import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/column.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/vertical_alignment.dart';
import '../../../fakes/builders/column_builder.dart';

void main() {
  group('Column', () {
    group('construction', () {
      test('should create column with correct required fields when id, containerId and index are provided', () {
        // Arrange & Act
        const column = Column(id: 1, containerId: 2, index: 0);

        // Assert
        expect(column.id, 1);
        expect(column.containerId, 2);
        expect(column.index, 0);
      });

      test('should default flex to null when not specified', () {
        // Arrange & Act
        const column = Column(id: 1, containerId: 1, index: 0);

        // Assert
        expect(column.flex, isNull);
      });

      test('should default width to null when not specified', () {
        // Arrange & Act
        const column = Column(id: 1, containerId: 1, index: 0);

        // Assert
        expect(column.width, isNull);
      });

      test('should default styleConfig to null when not specified', () {
        // Arrange & Act
        const column = Column(id: 1, containerId: 1, index: 0);

        // Assert
        expect(column.styleConfig, isNull);
      });

      test('should default isDroppable to true when not specified', () {
        // Arrange & Act
        const column = Column(id: 1, containerId: 1, index: 0);

        // Assert
        expect(column.isDroppable, isTrue);
      });

      test('should default dateCreated to null when not specified', () {
        // Arrange & Act
        const column = Column(id: 1, containerId: 1, index: 0);

        // Assert
        expect(column.dateCreated, isNull);
      });

      test('should default dateUpdated to null when not specified', () {
        // Arrange & Act
        const column = Column(id: 1, containerId: 1, index: 0);

        // Assert
        expect(column.dateUpdated, isNull);
      });

      test('should store all optional fields when all fields are provided', () {
        // Arrange
        final created = DateTime(2024, 1, 10);
        final updated = DateTime(2024, 1, 20);
        const style = StyleConfig(marginTop: 5.0);

        // Act
        final column = Column(
          id: 3,
          containerId: 7,
          index: 2,
          flex: 2,
          width: 300.0,
          styleConfig: style,
          isDroppable: false,
          dateCreated: created,
          dateUpdated: updated,
        );

        // Assert
        expect(column.flex, 2);
        expect(column.width, 300.0);
        expect(column.styleConfig, style);
        expect(column.isDroppable, isFalse);
        expect(column.dateCreated, created);
        expect(column.dateUpdated, updated);
      });

      test('should accept isDroppable false when explicitly set to false', () {
        // Arrange & Act
        const column = Column(id: 1, containerId: 1, index: 0, isDroppable: false);

        // Assert
        expect(column.isDroppable, isFalse);
      });

      test('should store styleConfig with BorderType when borderType is set', () {
        // Arrange & Act
        const column = Column(
          id: 1,
          containerId: 1,
          index: 0,
          styleConfig: StyleConfig(borderType: BorderType.dropShadow),
        );

        // Assert
        expect(column.styleConfig!.borderType, BorderType.dropShadow);
      });

      test('should store styleConfig with VerticalAlignment when verticalAlignment is set', () {
        // Arrange & Act
        const column = Column(
          id: 1,
          containerId: 1,
          index: 0,
          styleConfig: StyleConfig(verticalAlignment: VerticalAlignment.center),
        );

        // Assert
        expect(column.styleConfig!.verticalAlignment, VerticalAlignment.center);
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = Column(id: 1, containerId: 1, index: 0);
        const b = Column(id: 1, containerId: 1, index: 0);

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        const a = Column(id: 1, containerId: 1, index: 0);
        const b = Column(id: 1, containerId: 1, index: 0);

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const a = Column(id: 1, containerId: 1, index: 0);
        const b = Column(id: 2, containerId: 1, index: 0);

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when containerId differs', () {
        // Arrange
        const a = Column(id: 1, containerId: 1, index: 0);
        const b = Column(id: 1, containerId: 2, index: 0);

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when index differs', () {
        // Arrange
        const a = Column(id: 1, containerId: 1, index: 0);
        const b = Column(id: 1, containerId: 1, index: 1);

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('should update isDroppable to false when copyWith is called with false', () {
        // Arrange
        const column = Column(id: 1, containerId: 1, index: 0);

        // Act
        final updated = column.copyWith(isDroppable: false);

        // Assert
        expect(updated.isDroppable, isFalse);
      });

      test('should preserve id when only isDroppable is updated via copyWith', () {
        // Arrange
        const column = Column(id: 1, containerId: 1, index: 0);

        // Act
        final updated = column.copyWith(isDroppable: false);

        // Assert
        expect(updated.id, 1);
      });

      test('should update flex when copyWith is called with a new flex value', () {
        // Arrange
        const column = Column(id: 1, containerId: 1, index: 0);

        // Act
        final updated = column.copyWith(flex: 3);

        // Assert
        expect(updated.flex, 3);
      });

      test('should update width when copyWith is called with a new width value', () {
        // Arrange
        const column = Column(id: 1, containerId: 1, index: 0);

        // Act
        final updated = column.copyWith(width: 250.0);

        // Assert
        expect(updated.width, 250.0);
      });

      test('should update styleConfig when copyWith is called with a new StyleConfig', () {
        // Arrange
        const column = Column(id: 1, containerId: 1, index: 0);

        // Act
        final updated = column.copyWith(
          styleConfig: const StyleConfig(marginTop: 20.0),
        );

        // Assert
        expect(updated.styleConfig!.marginTop, 20.0);
      });

      test('should preserve unchanged fields when copyWith updates index only', () {
        // Arrange
        final column = buildColumn(id: 5, containerId: 3, index: 2, flex: 1);

        // Act
        final updated = column.copyWith(index: 4);

        // Assert
        expect(updated.id, 5);
        expect(updated.containerId, 3);
        expect(updated.flex, 1);
        expect(updated.index, 4);
      });
    });

    group('JSON serialization', () {
      test('should serialize required fields to JSON', () {
        // Arrange
        const column = Column(id: 1, containerId: 2, index: 3);

        // Act
        final json = column.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['containerId'], 2);
        expect(json['index'], 3);
      });

      test('should deserialize column from JSON with correct field values', () {
        // Arrange
        final json = {'id': 4, 'containerId': 5, 'index': 1, 'isDroppable': true};

        // Act
        final column = Column.fromJson(json);

        // Assert
        expect(column.id, 4);
        expect(column.containerId, 5);
        expect(column.index, 1);
        expect(column.isDroppable, isTrue);
      });

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        const original = Column(id: 7, containerId: 9, index: 2, flex: 1, width: 100.0);

        // Act
        final restored = Column.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        const column = Column(id: 1, containerId: 1, index: 0);

        // Act
        final result = column.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });
  });
}
