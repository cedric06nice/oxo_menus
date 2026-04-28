import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';

void main() {
  group('MenuChangeEvent', () {
    group('sealed hierarchy', () {
      test(
        'should be assignable to MenuChangeEvent when WidgetChangedEvent is created',
        () {
          // Arrange & Act
          final MenuChangeEvent event = WidgetChangedEvent(
            eventType: 'create',
            data: null,
            ids: null,
          );

          // Assert
          expect(event, isA<MenuChangeEvent>());
        },
      );

      test(
        'should be a WidgetChangedEvent when a WidgetChangedEvent is assigned to MenuChangeEvent',
        () {
          // Arrange & Act
          final MenuChangeEvent event = WidgetChangedEvent(
            eventType: 'create',
            data: null,
            ids: null,
          );

          // Assert
          expect(event, isA<WidgetChangedEvent>());
        },
      );
    });
  });

  group('WidgetChangedEvent', () {
    group('construction', () {
      test(
        'should store eventType, data and ids when all fields are provided',
        () {
          // Arrange & Act
          final event = WidgetChangedEvent(
            eventType: 'create',
            data: {'id': 1, 'type_key': 'dish'},
            ids: null,
          );

          // Assert
          expect(event.eventType, 'create');
          expect(event.data, {'id': 1, 'type_key': 'dish'});
          expect(event.ids, isNull);
        },
      );

      test('should store data map with nested values for update event', () {
        // Arrange & Act
        final event = WidgetChangedEvent(
          eventType: 'update',
          data: {'id': 1, 'type_key': 'dish', 'index': 2},
          ids: null,
        );

        // Assert
        expect(event.eventType, 'update');
        expect(event.data!['index'], 2);
      });

      test('should store ids list and null data for delete event', () {
        // Arrange & Act
        final event = WidgetChangedEvent(
          eventType: 'delete',
          data: null,
          ids: [1, 2, 3],
        );

        // Assert
        expect(event.eventType, 'delete');
        expect(event.data, isNull);
        expect(event.ids, [1, 2, 3]);
      });

      test('should accept null for both data and ids simultaneously', () {
        // Arrange & Act
        final event = WidgetChangedEvent(
          eventType: 'unknown',
          data: null,
          ids: null,
        );

        // Assert
        expect(event.data, isNull);
        expect(event.ids, isNull);
      });

      test('should store an empty data map when data is an empty map', () {
        // Arrange & Act
        final event = WidgetChangedEvent(
          eventType: 'create',
          data: {},
          ids: null,
        );

        // Assert
        expect(event.data, isEmpty);
      });

      test('should store an empty ids list when ids is an empty list', () {
        // Arrange & Act
        final event = WidgetChangedEvent(
          eventType: 'delete',
          data: null,
          ids: [],
        );

        // Assert
        expect(event.ids, isEmpty);
      });
    });

    group('pattern matching', () {
      test('should allow exhaustive switch on the sealed hierarchy', () {
        // Arrange
        final MenuChangeEvent event = WidgetChangedEvent(
          eventType: 'update',
          data: {'id': 5},
          ids: null,
        );

        // Act
        final result = switch (event) {
          WidgetChangedEvent(eventType: final type) => type,
        };

        // Assert
        expect(result, 'update');
      });

      test(
        'should allow extracting data map through switch when event carries data',
        () {
          // Arrange
          final MenuChangeEvent event = WidgetChangedEvent(
            eventType: 'create',
            data: {'id': 42},
            ids: null,
          );

          // Act
          Map<String, dynamic>? extractedData;
          switch (event) {
            case WidgetChangedEvent(:final data):
              extractedData = data;
          }

          // Assert
          expect(extractedData, {'id': 42});
        },
      );

      test(
        'should allow extracting ids list through switch when event carries ids',
        () {
          // Arrange
          final MenuChangeEvent event = WidgetChangedEvent(
            eventType: 'delete',
            data: null,
            ids: [7, 8],
          );

          // Act
          List<dynamic>? extractedIds;
          switch (event) {
            case WidgetChangedEvent(:final ids):
              extractedIds = ids;
          }

          // Assert
          expect(extractedIds, [7, 8]);
        },
      );
    });
  });
}
