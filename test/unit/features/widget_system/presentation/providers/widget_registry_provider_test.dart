import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/widget_system/presentation/providers/widget_registry_provider.dart';
import 'package:oxo_menus/features/widget_system/presentation/widget_system/presentable_widget_registry.dart';

void main() {
  group('allWidgetDefinitions', () {
    test('should contain exactly 8 widget definitions', () {
      expect(allWidgetDefinitions, hasLength(8));
    });

    test('should contain all expected widget type strings', () {
      final types = allWidgetDefinitions.map((d) => d.type).toSet();
      expect(
        types,
        containsAll([
          'dish',
          'dish_to_share',
          'image',
          'section',
          'set_menu_dish',
          'set_menu_title',
          'text',
          'wine',
        ]),
      );
    });

    test('should contain no duplicate widget type strings', () {
      final types = allWidgetDefinitions.map((d) => d.type).toList();
      final uniqueTypes = types.toSet();
      expect(types, hasLength(uniqueTypes.length));
    });
  });

  group('widgetRegistryProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should return a PresentableWidgetRegistry', () {
      expect(
        container.read(widgetRegistryProvider),
        isA<PresentableWidgetRegistry>(),
      );
    });

    test('should have all 8 widget types registered', () {
      final registry = container.read(widgetRegistryProvider);
      const expectedTypes = [
        'dish',
        'dish_to_share',
        'image',
        'section',
        'set_menu_dish',
        'set_menu_title',
        'text',
        'wine',
      ];
      for (final type in expectedTypes) {
        expect(
          registry.isRegistered(type),
          isTrue,
          reason: 'widget type "$type" should be registered',
        );
      }
    });

    test('should return null for an unregistered widget type', () {
      final registry = container.read(widgetRegistryProvider);
      expect(registry.getDefinition('unknown_type'), isNull);
    });

    test('should report 8 registered widget types via count', () {
      final registry = container.read(widgetRegistryProvider);
      expect(registry.count, 8);
    });

    test('should return the same registry instance on multiple reads', () {
      final r1 = container.read(widgetRegistryProvider);
      final r2 = container.read(widgetRegistryProvider);
      expect(identical(r1, r2), isTrue);
    });
  });
}
