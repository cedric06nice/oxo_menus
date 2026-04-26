import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/display_options_mapper.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';

void main() {
  group('DisplayOptionsMapper', () {
    group('fromJson', () {
      test('should parse showPrices and showAllergens from JSON', () {
        // Arrange
        final json = {'showPrices': false, 'showAllergens': true};

        // Act
        final options = DisplayOptionsMapper.fromJson(json);

        // Assert
        expect(options.showPrices, false);
        expect(options.showAllergens, true);
      });

      test('should default showPrices to true when key is absent', () {
        // Arrange
        final json = {'showAllergens': false};

        // Act
        final options = DisplayOptionsMapper.fromJson(json);

        // Assert
        expect(options.showPrices, true);
      });

      test('should default showAllergens to true when key is absent', () {
        // Arrange
        final json = {'showPrices': false};

        // Act
        final options = DisplayOptionsMapper.fromJson(json);

        // Assert
        expect(options.showAllergens, true);
      });

      test('should default both fields to true when JSON is empty', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final options = DisplayOptionsMapper.fromJson(json);

        // Assert
        expect(options.showPrices, true);
        expect(options.showAllergens, true);
      });

      test('should default showPrices to true when value is null', () {
        // Arrange
        final json = <String, dynamic>{
          'showPrices': null,
          'showAllergens': true,
        };

        // Act
        final options = DisplayOptionsMapper.fromJson(json);

        // Assert
        expect(options.showPrices, true);
      });

      test('should default showAllergens to true when value is null', () {
        // Arrange
        final json = <String, dynamic>{
          'showPrices': true,
          'showAllergens': null,
        };

        // Act
        final options = DisplayOptionsMapper.fromJson(json);

        // Assert
        expect(options.showAllergens, true);
      });

      test('should parse both fields as false', () {
        // Arrange
        final json = {'showPrices': false, 'showAllergens': false};

        // Act
        final options = DisplayOptionsMapper.fromJson(json);

        // Assert
        expect(options.showPrices, false);
        expect(options.showAllergens, false);
      });
    });

    group('toJson', () {
      test('should serialize showPrices and showAllergens', () {
        // Arrange
        const options = MenuDisplayOptions(
          showPrices: true,
          showAllergens: false,
        );

        // Act
        final json = DisplayOptionsMapper.toJson(options);

        // Assert
        expect(json['showPrices'], true);
        expect(json['showAllergens'], false);
      });

      test('should always include both keys even when both are true', () {
        // Arrange
        const options = MenuDisplayOptions(
          showPrices: true,
          showAllergens: true,
        );

        // Act
        final json = DisplayOptionsMapper.toJson(options);

        // Assert
        expect(json.containsKey('showPrices'), true);
        expect(json.containsKey('showAllergens'), true);
        expect(json, hasLength(2));
      });

      test('should always include both keys even when both are false', () {
        // Arrange
        const options = MenuDisplayOptions(
          showPrices: false,
          showAllergens: false,
        );

        // Act
        final json = DisplayOptionsMapper.toJson(options);

        // Assert
        expect(json['showPrices'], false);
        expect(json['showAllergens'], false);
      });
    });

    group('round-trip', () {
      test('should preserve values through fromJson then toJson', () {
        // Arrange
        final original = {'showPrices': false, 'showAllergens': true};

        // Act
        final entity = DisplayOptionsMapper.fromJson(original);
        final serialized = DisplayOptionsMapper.toJson(entity);

        // Assert
        expect(serialized['showPrices'], false);
        expect(serialized['showAllergens'], true);
      });

      test(
        'should preserve default values through round-trip starting from empty JSON',
        () {
          // Arrange
          final empty = <String, dynamic>{};

          // Act
          final entity = DisplayOptionsMapper.fromJson(empty);
          final serialized = DisplayOptionsMapper.toJson(entity);

          // Assert
          expect(serialized['showPrices'], true);
          expect(serialized['showAllergens'], true);
        },
      );
    });
  });
}
