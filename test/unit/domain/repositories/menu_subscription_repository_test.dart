import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/domain/repositories/menu_subscription_repository.dart';

/// Concrete implementation for testing the interface contract
class FakeMenuSubscriptionRepository implements MenuSubscriptionRepository {
  final Map<int, bool> _subscribed = {};

  @override
  Stream<MenuChangeEvent> subscribeToMenuChanges(int menuId) async* {
    _subscribed[menuId] = true;
    yield WidgetChangedEvent(eventType: 'create', data: {'id': 1}, ids: null);
  }

  @override
  Future<void> unsubscribe(int menuId) async {
    _subscribed.remove(menuId);
  }

  bool isSubscribed(int menuId) => _subscribed.containsKey(menuId);
}

void main() {
  group('MenuSubscriptionRepository', () {
    late FakeMenuSubscriptionRepository repository;

    setUp(() {
      repository = FakeMenuSubscriptionRepository();
    });

    test(
      'subscribeToMenuChanges returns a Stream of MenuChangeEvent',
      () async {
        final stream = repository.subscribeToMenuChanges(1);

        expect(stream, isA<Stream<MenuChangeEvent>>());

        final events = await stream.toList();
        expect(events, hasLength(1));
        expect(events.first, isA<WidgetChangedEvent>());
      },
    );

    test('unsubscribe removes active subscription', () async {
      // Start subscription (consume stream to trigger async*)
      await repository.subscribeToMenuChanges(1).toList();
      expect(repository.isSubscribed(1), isTrue);

      await repository.unsubscribe(1);
      expect(repository.isSubscribed(1), isFalse);
    });
  });
}
