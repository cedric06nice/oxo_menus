import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/mappers/style_config_mapper.dart';
import 'package:oxo_menus/domain/entities/border_type.dart';
import 'package:oxo_menus/domain/entities/menu.dart';

void main() {
  group('StyleConfigMapper', () {
    group('fromJson', () {
      test('should parse all StyleConfig fields from JSON', () {
        final json = <String, dynamic>{
          'fontFamily': 'Futura',
          'fontSize': 16.0,
          'primaryColor': '#000000',
          'secondaryColor': '#FFFFFF',
          'backgroundColor': '#F5F5F5',
          'marginTop': 20.0,
          'marginBottom': 30.0,
          'marginLeft': 15.0,
          'marginRight': 15.0,
          'padding': 10.0,
          'paddingTop': 12.0,
          'paddingBottom': 14.0,
          'paddingLeft': 8.0,
          'paddingRight': 8.0,
          'borderType': 'plain_thin',
        };

        final config = StyleConfigMapper.fromJson(json);

        expect(config.fontFamily, 'Futura');
        expect(config.fontSize, 16.0);
        expect(config.primaryColor, '#000000');
        expect(config.secondaryColor, '#FFFFFF');
        expect(config.backgroundColor, '#F5F5F5');
        expect(config.marginTop, 20.0);
        expect(config.marginBottom, 30.0);
        expect(config.marginLeft, 15.0);
        expect(config.marginRight, 15.0);
        expect(config.padding, 10.0);
        expect(config.paddingTop, 12.0);
        expect(config.paddingBottom, 14.0);
        expect(config.paddingLeft, 8.0);
        expect(config.paddingRight, 8.0);
        expect(config.borderType, BorderType.plainThin);
      });

      test('should handle empty JSON', () {
        final config = StyleConfigMapper.fromJson(<String, dynamic>{});

        expect(config.fontFamily, isNull);
        expect(config.fontSize, isNull);
        expect(config.marginTop, isNull);
        expect(config.borderType, isNull);
      });

      test('should handle null borderType', () {
        final json = <String, dynamic>{'marginTop': 10.0};

        final config = StyleConfigMapper.fromJson(json);

        expect(config.marginTop, 10.0);
        expect(config.borderType, isNull);
      });

      test('should parse integer margins as double', () {
        final json = <String, dynamic>{'marginTop': 10, 'paddingLeft': 5};

        final config = StyleConfigMapper.fromJson(json);

        expect(config.marginTop, 10.0);
        expect(config.paddingLeft, 5.0);
      });
    });

    group('toJson', () {
      test('should serialize all non-null fields', () {
        const config = StyleConfig(
          fontFamily: 'Futura',
          fontSize: 16.0,
          primaryColor: '#000000',
          marginTop: 20.0,
          marginBottom: 30.0,
          paddingTop: 12.0,
          borderType: BorderType.plainThin,
        );

        final json = StyleConfigMapper.toJson(config);

        expect(json['fontFamily'], 'Futura');
        expect(json['fontSize'], 16.0);
        expect(json['primaryColor'], '#000000');
        expect(json['marginTop'], 20.0);
        expect(json['marginBottom'], 30.0);
        expect(json['paddingTop'], 12.0);
        expect(json['borderType'], 'plain_thin');
      });

      test('should omit null fields', () {
        const config = StyleConfig(marginTop: 10.0);

        final json = StyleConfigMapper.toJson(config);

        expect(json.containsKey('marginTop'), true);
        expect(json.containsKey('fontFamily'), false);
        expect(json.containsKey('borderType'), false);
        expect(json.containsKey('fontSize'), false);
      });

      test('should return empty map for default StyleConfig', () {
        const config = StyleConfig();

        final json = StyleConfigMapper.toJson(config);

        expect(json, isEmpty);
      });

      test('should round-trip correctly', () {
        const original = StyleConfig(
          marginTop: 20.0,
          paddingLeft: 8.0,
          borderType: BorderType.dropShadow,
          fontSize: 14.0,
        );

        final json = StyleConfigMapper.toJson(original);
        final restored = StyleConfigMapper.fromJson(json);

        expect(restored.marginTop, original.marginTop);
        expect(restored.paddingLeft, original.paddingLeft);
        expect(restored.borderType, original.borderType);
        expect(restored.fontSize, original.fontSize);
      });
    });
  });
}
