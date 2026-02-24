import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/repositories/menu_subscription_repository_impl.dart';
import 'package:oxo_menus/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';
import 'package:oxo_menus/main.reflectable.dart';

class MockDirectusDataSource extends Mock implements DirectusDataSource {}

void main() {
  late MenuSubscriptionRepository repository;
  late MockDirectusDataSource mockDataSource;

  setUpAll(() {
    initializeReflectable();
  });

  setUp(() {
    mockDataSource = MockDirectusDataSource();
    repository = MenuSubscriptionRepositoryImpl(dataSource: mockDataSource);
    registerFallbackValue(_FakeSubscription());
  });

  group('MenuSubscriptionRepositoryImpl', () {
    group('subscribeToMenuChanges', () {
      test('should start a WebSocket subscription via data source', () async {
        when(
          () => mockDataSource.startSubscription(any()),
        ).thenAnswer((_) async {});

        // Subscribe and listen to trigger the stream setup
        final stream = repository.subscribeToMenuChanges(42);
        final subscription = stream.listen((_) {});

        // Give async stream setup time to complete
        await Future<void>.delayed(Duration.zero);

        verify(() => mockDataSource.startSubscription(any())).called(1);

        await subscription.cancel();
      });

      test('should emit WidgetChangedEvent on create callback', () async {
        DirectusWebSocketSubscription? capturedSubscription;

        when(() => mockDataSource.startSubscription(any())).thenAnswer((inv) {
          capturedSubscription =
              inv.positionalArguments[0] as DirectusWebSocketSubscription;
          return Future.value();
        });

        final stream = repository.subscribeToMenuChanges(42);
        final events = <MenuChangeEvent>[];
        final sub = stream.listen(events.add);

        await Future<void>.delayed(Duration.zero);

        // Simulate a create event from the WebSocket
        capturedSubscription!.onCreate!({
          'id': 1,
          'type_key': 'dish',
          'index': 0,
        });

        await Future<void>.delayed(Duration.zero);

        expect(events, hasLength(1));
        expect(events.first, isA<WidgetChangedEvent>());
        final event = events.first as WidgetChangedEvent;
        expect(event.eventType, 'create');
        expect(event.data?['id'], 1);

        await sub.cancel();
      });

      test('should emit WidgetChangedEvent on update callback', () async {
        DirectusWebSocketSubscription? capturedSubscription;

        when(() => mockDataSource.startSubscription(any())).thenAnswer((inv) {
          capturedSubscription =
              inv.positionalArguments[0] as DirectusWebSocketSubscription;
          return Future.value();
        });

        final stream = repository.subscribeToMenuChanges(42);
        final events = <MenuChangeEvent>[];
        final sub = stream.listen(events.add);

        await Future<void>.delayed(Duration.zero);

        capturedSubscription!.onUpdate!({
          'id': 1,
          'type_key': 'dish',
          'index': 2,
        });

        await Future<void>.delayed(Duration.zero);

        expect(events, hasLength(1));
        final event = events.first as WidgetChangedEvent;
        expect(event.eventType, 'update');

        await sub.cancel();
      });

      test('should emit WidgetChangedEvent on delete callback', () async {
        DirectusWebSocketSubscription? capturedSubscription;

        when(() => mockDataSource.startSubscription(any())).thenAnswer((inv) {
          capturedSubscription =
              inv.positionalArguments[0] as DirectusWebSocketSubscription;
          return Future.value();
        });

        final stream = repository.subscribeToMenuChanges(42);
        final events = <MenuChangeEvent>[];
        final sub = stream.listen(events.add);

        await Future<void>.delayed(Duration.zero);

        capturedSubscription!.onDelete!({
          'ids': [1, 2],
        });

        await Future<void>.delayed(Duration.zero);

        expect(events, hasLength(1));
        final event = events.first as WidgetChangedEvent;
        expect(event.eventType, 'delete');

        await sub.cancel();
      });

      test('should use filter targeting the given menuId', () async {
        DirectusWebSocketSubscription? capturedSubscription;

        when(() => mockDataSource.startSubscription(any())).thenAnswer((inv) {
          capturedSubscription =
              inv.positionalArguments[0] as DirectusWebSocketSubscription;
          return Future.value();
        });

        final stream = repository.subscribeToMenuChanges(42);
        final sub = stream.listen((_) {});

        await Future<void>.delayed(Duration.zero);

        // Verify the filter contains the menuId
        expect(capturedSubscription, isNotNull);
        final filter = capturedSubscription!.filter;
        expect(filter, isNotNull);

        // The filter should produce a JSON/Map that references menu = 42
        final filterMap = filter!.asMap;
        // RelationFilter nests: column -> container -> page -> menu._eq: 42
        expect(filterMap, containsPair('column', isA<Map>()));

        await sub.cancel();
      });
    });

    group('unsubscribe', () {
      test(
        'should stop the WebSocket subscription for the given menuId',
        () async {
          when(
            () => mockDataSource.startSubscription(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockDataSource.stopSubscription(any()),
          ).thenAnswer((_) async {});

          final stream = repository.subscribeToMenuChanges(42);
          final sub = stream.listen((_) {});

          await Future<void>.delayed(Duration.zero);

          await repository.unsubscribe(42);

          verify(() => mockDataSource.stopSubscription(any())).called(1);

          await sub.cancel();
        },
      );

      test(
        'should do nothing if no subscription exists for the menuId',
        () async {
          when(
            () => mockDataSource.stopSubscription(any()),
          ).thenAnswer((_) async {});

          // Unsubscribe without subscribing first — should not throw
          await repository.unsubscribe(999);

          verifyNever(() => mockDataSource.stopSubscription(any()));
        },
      );
    });
  });
}

class _FakeSubscription extends Fake
    implements DirectusWebSocketSubscription<DirectusItem> {}
