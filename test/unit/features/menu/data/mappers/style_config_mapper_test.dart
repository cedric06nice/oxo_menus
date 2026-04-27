import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/data/mappers/style_config_mapper.dart';
import 'package:oxo_menus/shared/domain/entities/border_type.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/shared/domain/entities/vertical_alignment.dart';

void main() {
  group('StyleConfigMapper', () {
    group('fromJson', () {
      test('should parse all typography fields', () {
        // Arrange
        final json = {
          'fontFamily': 'Georgia',
          'fontSize': 16.0,
          'primaryColor': '#111111',
          'secondaryColor': '#222222',
          'backgroundColor': '#FAFAFA',
        };

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.fontFamily, 'Georgia');
        expect(config.fontSize, 16.0);
        expect(config.primaryColor, '#111111');
        expect(config.secondaryColor, '#222222');
        expect(config.backgroundColor, '#FAFAFA');
      });

      test('should parse all margin fields', () {
        // Arrange
        final json = {
          'marginTop': 10.0,
          'marginBottom': 12.0,
          'marginLeft': 8.0,
          'marginRight': 8.0,
        };

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.marginTop, 10.0);
        expect(config.marginBottom, 12.0);
        expect(config.marginLeft, 8.0);
        expect(config.marginRight, 8.0);
      });

      test('should parse all padding fields', () {
        // Arrange
        final json = {
          'padding': 4.0,
          'paddingTop': 5.0,
          'paddingBottom': 6.0,
          'paddingLeft': 7.0,
          'paddingRight': 8.0,
        };

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.padding, 4.0);
        expect(config.paddingTop, 5.0);
        expect(config.paddingBottom, 6.0);
        expect(config.paddingLeft, 7.0);
        expect(config.paddingRight, 8.0);
      });

      test('should parse borderType "none"', () {
        // Arrange
        final json = {'borderType': 'none'};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.borderType, BorderType.none);
      });

      test('should parse borderType "plain_thin"', () {
        // Arrange
        final json = {'borderType': 'plain_thin'};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.borderType, BorderType.plainThin);
      });

      test('should parse borderType "plain_thick"', () {
        // Arrange
        final json = {'borderType': 'plain_thick'};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.borderType, BorderType.plainThick);
      });

      test('should parse borderType "double_offset"', () {
        // Arrange
        final json = {'borderType': 'double_offset'};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.borderType, BorderType.doubleOffset);
      });

      test('should parse borderType "drop_shadow"', () {
        // Arrange
        final json = {'borderType': 'drop_shadow'};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.borderType, BorderType.dropShadow);
      });

      test('should set borderType to null when key is absent', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.borderType, isNull);
      });

      test('should parse verticalAlignment "top"', () {
        // Arrange
        final json = {'verticalAlignment': 'top'};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.verticalAlignment, VerticalAlignment.top);
      });

      test('should parse verticalAlignment "center"', () {
        // Arrange
        final json = {'verticalAlignment': 'center'};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.verticalAlignment, VerticalAlignment.center);
      });

      test('should parse verticalAlignment "bottom"', () {
        // Arrange
        final json = {'verticalAlignment': 'bottom'};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.verticalAlignment, VerticalAlignment.bottom);
      });

      test('should set verticalAlignment to null when key is absent', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.verticalAlignment, isNull);
      });

      test('should coerce integer numeric fields to double', () {
        // Arrange
        final json = {'fontSize': 14, 'marginTop': 10, 'padding': 8};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.fontSize, isA<double>());
        expect(config.marginTop, isA<double>());
        expect(config.padding, isA<double>());
        expect(config.fontSize, 14.0);
      });

      test('should set all fields to null when JSON is empty', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final config = StyleConfigMapper.fromJson(json);

        // Assert
        expect(config.fontFamily, isNull);
        expect(config.fontSize, isNull);
        expect(config.primaryColor, isNull);
        expect(config.secondaryColor, isNull);
        expect(config.backgroundColor, isNull);
        expect(config.marginTop, isNull);
        expect(config.marginBottom, isNull);
        expect(config.marginLeft, isNull);
        expect(config.marginRight, isNull);
        expect(config.padding, isNull);
        expect(config.paddingTop, isNull);
        expect(config.paddingBottom, isNull);
        expect(config.paddingLeft, isNull);
        expect(config.paddingRight, isNull);
        expect(config.borderType, isNull);
        expect(config.verticalAlignment, isNull);
      });
    });

    group('toJson', () {
      test('should omit all null fields producing an empty map', () {
        // Arrange
        const config = StyleConfig();

        // Act
        final json = StyleConfigMapper.toJson(config);

        // Assert
        expect(json, isEmpty);
      });

      test('should include only non-null fields', () {
        // Arrange
        const config = StyleConfig(fontFamily: 'Arial', fontSize: 14.0);

        // Act
        final json = StyleConfigMapper.toJson(config);

        // Assert
        expect(json, hasLength(2));
        expect(json['fontFamily'], 'Arial');
        expect(json['fontSize'], 14.0);
      });

      test('should serialize borderType as its string representation', () {
        // Arrange
        const config = StyleConfig(borderType: BorderType.dropShadow);

        // Act
        final json = StyleConfigMapper.toJson(config);

        // Assert
        expect(json['borderType'], 'drop_shadow');
      });

      test(
        'should serialize verticalAlignment as its string representation',
        () {
          // Arrange
          const config = StyleConfig(
            verticalAlignment: VerticalAlignment.center,
          );

          // Act
          final json = StyleConfigMapper.toJson(config);

          // Assert
          expect(json['verticalAlignment'], 'center');
        },
      );

      test('should serialize all margin and padding fields when provided', () {
        // Arrange
        const config = StyleConfig(
          marginTop: 5.0,
          marginBottom: 6.0,
          marginLeft: 7.0,
          marginRight: 8.0,
          padding: 3.0,
          paddingTop: 1.0,
          paddingBottom: 2.0,
          paddingLeft: 3.0,
          paddingRight: 4.0,
        );

        // Act
        final json = StyleConfigMapper.toJson(config);

        // Assert
        expect(json['marginTop'], 5.0);
        expect(json['marginBottom'], 6.0);
        expect(json['marginLeft'], 7.0);
        expect(json['marginRight'], 8.0);
        expect(json['padding'], 3.0);
        expect(json['paddingTop'], 1.0);
        expect(json['paddingBottom'], 2.0);
        expect(json['paddingLeft'], 3.0);
        expect(json['paddingRight'], 4.0);
      });

      test('should serialize all color fields when provided', () {
        // Arrange
        const config = StyleConfig(
          primaryColor: '#FF0000',
          secondaryColor: '#00FF00',
          backgroundColor: '#0000FF',
        );

        // Act
        final json = StyleConfigMapper.toJson(config);

        // Assert
        expect(json['primaryColor'], '#FF0000');
        expect(json['secondaryColor'], '#00FF00');
        expect(json['backgroundColor'], '#0000FF');
      });
    });

    group('round-trip', () {
      test(
        'should preserve a fully-populated config through fromJson then toJson',
        () {
          // Arrange
          final original = {
            'fontFamily': 'Helvetica',
            'fontSize': 12.0,
            'primaryColor': '#AABBCC',
            'marginTop': 10.0,
            'paddingLeft': 4.0,
            'borderType': 'plain_thin',
            'verticalAlignment': 'bottom',
          };

          // Act
          final config = StyleConfigMapper.fromJson(original);
          final serialized = StyleConfigMapper.toJson(config);

          // Assert
          expect(serialized['fontFamily'], 'Helvetica');
          expect(serialized['fontSize'], 12.0);
          expect(serialized['primaryColor'], '#AABBCC');
          expect(serialized['marginTop'], 10.0);
          expect(serialized['paddingLeft'], 4.0);
          expect(serialized['borderType'], 'plain_thin');
          expect(serialized['verticalAlignment'], 'bottom');
        },
      );
    });
  });
}
