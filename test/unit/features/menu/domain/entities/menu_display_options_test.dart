import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';

void main() {
  group('MenuDisplayOptions', () {
    group('construction', () {
      test('should default showPrices to true when not specified', () {
        // Arrange & Act
        const options = MenuDisplayOptions();

        // Assert
        expect(options.showPrices, isTrue);
      });

      test('should default showAllergens to true when not specified', () {
        // Arrange & Act
        const options = MenuDisplayOptions();

        // Assert
        expect(options.showAllergens, isTrue);
      });

      test('should store showPrices false when explicitly set to false', () {
        // Arrange & Act
        const options = MenuDisplayOptions(showPrices: false);

        // Assert
        expect(options.showPrices, isFalse);
      });

      test('should store showAllergens false when explicitly set to false', () {
        // Arrange & Act
        const options = MenuDisplayOptions(showAllergens: false);

        // Assert
        expect(options.showAllergens, isFalse);
      });

      test(
        'should store both fields false when both are explicitly set to false',
        () {
          // Arrange & Act
          const options = MenuDisplayOptions(
            showPrices: false,
            showAllergens: false,
          );

          // Assert
          expect(options.showPrices, isFalse);
          expect(options.showAllergens, isFalse);
        },
      );
    });

    group('equality', () {
      test('should be equal when both fields have the same values', () {
        // Arrange
        const a = MenuDisplayOptions(showPrices: true, showAllergens: false);
        const b = MenuDisplayOptions(showPrices: true, showAllergens: false);

        // Assert
        expect(a, equals(b));
      });

      test('should produce the same hashCode when both fields are equal', () {
        // Arrange
        const a = MenuDisplayOptions(showPrices: false, showAllergens: true);
        const b = MenuDisplayOptions(showPrices: false, showAllergens: true);

        // Assert
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should not be equal when showPrices differs', () {
        // Arrange
        const a = MenuDisplayOptions(showPrices: true, showAllergens: true);
        const b = MenuDisplayOptions(showPrices: false, showAllergens: true);

        // Assert
        expect(a, isNot(equals(b)));
      });

      test('should not be equal when showAllergens differs', () {
        // Arrange
        const a = MenuDisplayOptions(showPrices: true, showAllergens: true);
        const b = MenuDisplayOptions(showPrices: true, showAllergens: false);

        // Assert
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('should update showPrices when copyWith is called with false', () {
        // Arrange
        const options = MenuDisplayOptions(
          showPrices: true,
          showAllergens: true,
        );

        // Act
        final updated = options.copyWith(showPrices: false);

        // Assert
        expect(updated.showPrices, isFalse);
        expect(updated.showAllergens, isTrue);
      });

      test(
        'should update showAllergens when copyWith is called with false',
        () {
          // Arrange
          const options = MenuDisplayOptions(
            showPrices: true,
            showAllergens: true,
          );

          // Act
          final updated = options.copyWith(showAllergens: false);

          // Assert
          expect(updated.showAllergens, isFalse);
          expect(updated.showPrices, isTrue);
        },
      );

      test(
        'should preserve all fields when copyWith is called with no arguments',
        () {
          // Arrange
          const options = MenuDisplayOptions(
            showPrices: false,
            showAllergens: true,
          );

          // Act
          final copy = options.copyWith();

          // Assert
          expect(copy, equals(options));
        },
      );
    });

    group('toString', () {
      test('should produce a non-empty string', () {
        // Arrange
        const options = MenuDisplayOptions();

        // Act
        final result = options.toString();

        // Assert
        expect(result, isNotEmpty);
      });
    });

    group('JSON serialization', () {
      test('should serialize showPrices and showAllergens to JSON', () {
        // Arrange
        const options = MenuDisplayOptions(
          showPrices: true,
          showAllergens: false,
        );

        // Act
        final json = options.toJson();

        // Assert
        expect(json['showPrices'], isTrue);
        expect(json['showAllergens'], isFalse);
      });

      test(
        'should deserialize MenuDisplayOptions from JSON with correct field values',
        () {
          // Arrange
          final json = {'showPrices': false, 'showAllergens': true};

          // Act
          final options = MenuDisplayOptions.fromJson(json);

          // Assert
          expect(options.showPrices, isFalse);
          expect(options.showAllergens, isTrue);
        },
      );

      test('should round-trip through JSON preserving equality', () {
        // Arrange
        const original = MenuDisplayOptions(
          showPrices: false,
          showAllergens: true,
        );

        // Act
        final restored = MenuDisplayOptions.fromJson(original.toJson());

        // Assert
        expect(restored, equals(original));
      });

      test('should use defaults when JSON does not contain the fields', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final options = MenuDisplayOptions.fromJson(json);

        // Assert
        expect(options.showPrices, isTrue);
        expect(options.showAllergens, isTrue);
      });
    });
  });
}
