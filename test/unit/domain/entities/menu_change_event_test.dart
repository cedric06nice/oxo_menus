import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_change_event.dart';

void main() {
  group('MenuChangeEvent', () {
    group('WidgetChangedEvent', () {
      test('should store create event type with data', () {
        final event = WidgetChangedEvent(
          eventType: 'create',
          data: {'id': 1, 'type_key': 'dish'},
          ids: null,
        );

        expect(event.eventType, 'create');
        expect(event.data, {'id': 1, 'type_key': 'dish'});
        expect(event.ids, isNull);
      });

      test('should store update event type with data', () {
        final event = WidgetChangedEvent(
          eventType: 'update',
          data: {'id': 1, 'type_key': 'dish', 'index': 2},
          ids: null,
        );

        expect(event.eventType, 'update');
        expect(event.data?['index'], 2);
      });

      test('should store delete event type with ids', () {
        final event = WidgetChangedEvent(
          eventType: 'delete',
          data: null,
          ids: [1, 2, 3],
        );

        expect(event.eventType, 'delete');
        expect(event.data, isNull);
        expect(event.ids, [1, 2, 3]);
      });

      test('should be a subtype of MenuChangeEvent', () {
        final MenuChangeEvent event = WidgetChangedEvent(
          eventType: 'create',
          data: null,
          ids: null,
        );

        expect(event, isA<MenuChangeEvent>());
        expect(event, isA<WidgetChangedEvent>());
      });

      test('should support pattern matching via switch', () {
        final MenuChangeEvent event = WidgetChangedEvent(
          eventType: 'update',
          data: {'id': 5},
          ids: null,
        );

        final result = switch (event) {
          WidgetChangedEvent(eventType: final type) => type,
        };

        expect(result, 'update');
      });
    });
  });
}
