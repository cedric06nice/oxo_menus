import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/container.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import '../../../fakes/builders/container_builder.dart';

void main() {
  group('Container', () {
    group('construction', () {
      test(
        'should create container with correct required fields when id, pageId and index are provided',
        () {
          // Arrange & Act
          const container = Container(id: 1, pageId: 2, index: 0);

          // Assert
          expect(container.id, 1);
          expect(container.pageId, 2);
          expect(container.index, 0);
        },
      );

      test('should default name to null when not specified', () {
        // Arrange & Act
        const container = Container(id: 1, pageId: 1, index: 0);

        // Assert
        expect(container.name, isNull);
      });

      test('should default parentContainerId to null when not specified', () {
        // Arrange & Act
        const container = Container(id: 1, pageId: 1, index: 0);

        // Assert
        expect(container.parentContainerId, isNull);
      });

      test('should default layout to null when not specified', () {
        // Arrange & Act
        const container = Container(id: 1, pageId: 1, index: 0);

        // Assert
        expect(container.layout, isNull);
      });

      test('should default styleConfig to null when not specified', () {
        // Arrange & Act
        const container = Container(id: 1, pageId: 1, index: 0);

        // Assert
        expect(container.styleConfig, isNull);
      });

      test('should default dateCreated to null when not specified', () {
        // Arrange & Act
        const container = Container(id: 1, pageId: 1, index: 0);

        // Assert
        expect(container.dateCreated, isNull);
      });

      test('should default dateUpdated to null when not specified', () {
        // Arrange & Act
        const container = Container(id: 1, pageId: 1, index: 0);

        // Assert
        expect(container.dateUpdated, isNull);
      });

      test(
        'should store parentContainerId when parentContainerId is provided',
        () {
          // Arrange & Act
          const container = Container(
            id: 2,
            pageId: 1,
            index: 0,
            parentContainerId: 1,
          );

          // Assert
          expect(container.parentContainerId, 1);
        },
      );

      test('should store name when name is provided', () {
        // Arrange & Act
        const container = Container(id: 1, pageId: 1, index: 0, name: 'Header');

        // Assert
        expect(container.name, 'Header');
      });

      test(
        'should store styleConfig with borderType when borderType is set',
        () {
          // Arrange & Act
          const container = Container(
            id: 1,
            pageId: 1,
            index: 0,
            styleConfig: StyleConfig(
              marginTop: 10.0,
              borderType: BorderType.plainThin,
            ),
          );

          // Assert
          expect(container.styleConfig!.marginTop, 10.0);
          expect(container.styleConfig!.borderType, BorderType.plainThin);
        },
      );

      test('should store all optional fields when fully specified', () {
        // Arrange
        final created = DateTime(2024, 3, 1);
        final updated = DateTime(2024, 3, 15);
        const layout = LayoutConfig(direction: 'row');
        const style = StyleConfig(padding: 8.0);

        // Act
        final container = Container(
          id: 5,
          pageId: 3,
          index: 2,
          name: 'Section',
          parentContainerId: 4,
          layout: layout,
          styleConfig: style,
          dateCreated: created,
          dateUpdated: updated,
        );

        // Assert
        expect(container.name, 'Section');
        expect(container.parentContainerId, 4);
        expect(container.layout, layout);
        expect(container.styleConfig, style);
        expect(container.dateCreated, created);
        expect(container.dateUpdated, updated);
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = Container(id: 1, pageId: 1, index: 0);
        const b = Container(id: 1, pageId: 1, index: 0);

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when all fields are equal', () {
        // Arrange
        const a = Container(id: 1, pageId: 1, index: 0);
        const b = Container(id: 1, pageId: 1, index: 0);

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        const a = Container(id: 1, pageId: 1, index: 0);
        const b = Container(id: 2, pageId: 1, index: 0);

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when pageId differs', () {
        // Arrange
        const a = Container(id: 1, pageId: 1, index: 0);
        const b = Container(id: 1, pageId: 2, index: 0);

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test(
        'should update styleConfig when copyWith is called with a new StyleConfig',
        () {
          // Arrange
          const container = Container(id: 1, pageId: 1, index: 0);

          // Act
          final updated = container.copyWith(
            styleConfig: const StyleConfig(paddingLeft: 5.0),
          );

          // Assert
          expect(updated.styleConfig!.paddingLeft, 5.0);
        },
      );

      test(
        'should update parentContainerId when copyWith is called with a new id',
        () {
          // Arrange
          const container = Container(id: 1, pageId: 1, index: 0);

          // Act
          final updated = container.copyWith(parentContainerId: 5);

          // Assert
          expect(updated.parentContainerId, 5);
        },
      );

      test('should update name when copyWith is called with a new name', () {
        // Arrange
        const container = Container(id: 1, pageId: 1, index: 0);

        // Act
        final updated = container.copyWith(name: 'Footer');

        // Assert
        expect(updated.name, 'Footer');
      });

      test('should update index when copyWith is called with a new index', () {
        // Arrange
        const container = Container(id: 1, pageId: 1, index: 0);

        // Act
        final updated = container.copyWith(index: 3);

        // Assert
        expect(updated.index, 3);
      });

      test(
        'should preserve unchanged fields when only name is updated via copyWith',
        () {
          // Arrange
          final container = buildContainer(id: 7, pageId: 2, index: 1);

          // Act
          final updated = container.copyWith(name: 'New Name');

          // Assert
          expect(updated.id, 7);
          expect(updated.pageId, 2);
          expect(updated.index, 1);
        },
      );
    });

    group('JSON serialization', () {
      test('should serialize required fields to JSON', () {
        // Arrange
        const container = Container(id: 1, pageId: 2, index: 3);

        // Act
        final json = container.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['pageId'], 2);
        expect(json['index'], 3);
      });

      test(
        'should deserialize container from JSON with correct field values',
        () {
          // Arrange
          final json = {'id': 4, 'pageId': 5, 'index': 1};

          // Act
          final container = Container.fromJson(json);

          // Assert
          expect(container.id, 4);
          expect(container.pageId, 5);
          expect(container.index, 1);
        },
      );

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        const original = Container(id: 7, pageId: 9, index: 2, name: 'Body');

        // Act
        final restored = Container.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        const container = Container(id: 1, pageId: 1, index: 0);

        // Act
        final result = container.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });
  });

  group('LayoutConfig', () {
    group('construction', () {
      test('should create LayoutConfig with all fields null by default', () {
        // Arrange & Act
        const layout = LayoutConfig();

        // Assert
        expect(layout.direction, isNull);
        expect(layout.alignment, isNull);
        expect(layout.mainAxisAlignment, isNull);
        expect(layout.spacing, isNull);
      });

      test('should store direction when provided', () {
        // Arrange & Act
        const layout = LayoutConfig(direction: 'row');

        // Assert
        expect(layout.direction, 'row');
      });

      test('should store mainAxisAlignment when provided', () {
        // Arrange & Act
        const layout = LayoutConfig(mainAxisAlignment: 'center');

        // Assert
        expect(layout.mainAxisAlignment, 'center');
      });

      test('should store spacing when provided', () {
        // Arrange & Act
        const layout = LayoutConfig(spacing: 8.0);

        // Assert
        expect(layout.spacing, 8.0);
      });
    });

    group('equality', () {
      test('should be equal when all fields have the same values', () {
        // Arrange
        const a = LayoutConfig(direction: 'row', spacing: 4.0);
        const b = LayoutConfig(direction: 'row', spacing: 4.0);

        // Assert
        expect(a, equals(b));
      });

      test('should not be equal when direction differs', () {
        // Arrange
        const a = LayoutConfig(direction: 'row');
        const b = LayoutConfig(direction: 'column');

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test(
        'should update spacing when copyWith is called with a new spacing value',
        () {
          // Arrange
          const layout = LayoutConfig(direction: 'row');

          // Act
          final updated = layout.copyWith(spacing: 12.0);

          // Assert
          expect(updated.spacing, 12.0);
          expect(updated.direction, 'row');
        },
      );
    });

    group('JSON serialization', () {
      test('should serialize all fields to JSON', () {
        // Arrange
        const layout = LayoutConfig(
          direction: 'column',
          mainAxisAlignment: 'spaceBetween',
          spacing: 8.0,
        );

        // Act
        final json = layout.toJson();

        // Assert
        expect(json['direction'], 'column');
        expect(json['mainAxisAlignment'], 'spaceBetween');
        expect(json['spacing'], 8.0);
      });

      test(
        'should deserialize LayoutConfig from JSON with correct field values',
        () {
          // Arrange
          final json = {'direction': 'row', 'mainAxisAlignment': 'spaceEvenly'};

          // Act
          final layout = LayoutConfig.fromJson(json);

          // Assert
          expect(layout.direction, 'row');
          expect(layout.mainAxisAlignment, 'spaceEvenly');
        },
      );

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        const original = LayoutConfig(
          direction: 'row',
          alignment: 'start',
          spacing: 4.0,
        );

        // Act
        final restored = LayoutConfig.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });
    });
  });
}
