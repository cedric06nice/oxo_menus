import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:oxo_menus/data/datasources/directus_data_source.dart';

import '../../../fakes/fake_directus_websocket_subscription.dart';
import '../../../fakes/fake_secure_token_storage.dart';
import '../../../fakes/reflectable_bootstrap.dart';

// ---------------------------------------------------------------------------
// FakeDirectusApiManager (WebSocket-focused)
//
// Extends DirectusApiManager and overrides only the WebSocket methods.
// Records calls and supports configurable failure injection.
// ---------------------------------------------------------------------------

class FakeDirectusApiManagerWs extends DirectusApiManager {
  FakeDirectusApiManagerWs()
    : super(baseURL: 'http://localhost:8055', httpClient: http.Client());

  final List<String> calledMethods = [];

  // --- startWebsocketSubscription ---
  Object? _startError;
  DirectusWebSocketSubscription? _lastStartedSubscription;

  void stubStartSubscriptionThrows(Object error) {
    _startError = error;
  }

  DirectusWebSocketSubscription? get lastStartedSubscription =>
      _lastStartedSubscription;

  @override
  Future<void> startWebsocketSubscription(
    DirectusWebSocketSubscription subscription,
  ) async {
    calledMethods.add('startWebsocketSubscription');
    _lastStartedSubscription = subscription;
    if (_startError != null) throw _startError!;
  }

  // --- stopWebsocketSubscription ---
  String? _lastStoppedUid;

  String? get lastStoppedUid => _lastStoppedUid;

  @override
  Future<void> stopWebsocketSubscription(
    String webSocketSubscriptionId,
  ) async {
    calledMethods.add('stopWebsocketSubscription');
    _lastStoppedUid = webSocketSubscriptionId;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(initializeReflectableForTests);

  late FakeDirectusApiManagerWs fakeApiManager;
  late FakeSecureTokenStorage fakeStorage;
  late DirectusDataSource dataSource;

  setUp(() {
    fakeApiManager = FakeDirectusApiManagerWs();
    fakeStorage = FakeSecureTokenStorage();
    dataSource = DirectusDataSource(
      baseUrl: 'http://localhost:8055',
      apiManager: fakeApiManager,
      tokenStorage: fakeStorage,
    );
  });

  // =========================================================================
  group('DirectusDataSource WebSocket', () {
    // -----------------------------------------------------------------------
    group('startSubscription', () {
      test(
          'should delegate to apiManager.startWebsocketSubscription with the given subscription',
          () async {
        // Arrange
        final subscription = FakeDirectusWebSocketSubscription(
          uid: 'menu-subscription-1',
        );

        // Act
        await dataSource.startSubscription(subscription);

        // Assert
        expect(
          fakeApiManager.calledMethods,
          contains('startWebsocketSubscription'),
        );
        expect(fakeApiManager.lastStartedSubscription, same(subscription));
      });

      test('should pass through a DirectusException from apiManager', () async {
        // Arrange
        final subscription = FakeDirectusWebSocketSubscription(uid: 'sub-err');
        fakeApiManager.stubStartSubscriptionThrows(
          DirectusException(
            code: 'WEBSOCKET_FAILED',
            message: 'Cannot connect',
          ),
        );

        // Act & Assert
        await expectLater(
          () => dataSource.startSubscription(subscription),
          throwsA(isA<DirectusException>()),
        );
      });

      test('should call apiManager with the subscription object unchanged',
          () async {
        // Arrange
        final subscription = FakeDirectusWebSocketSubscription(uid: 'sub-42');
        subscription.onCreate = (_) => null;

        // Act
        await dataSource.startSubscription(subscription);

        // Assert
        final received = fakeApiManager.lastStartedSubscription;
        expect(received?.uid, 'sub-42');
      });
    });

    // -----------------------------------------------------------------------
    group('stopSubscription', () {
      test(
          'should delegate to apiManager.stopWebsocketSubscription with the given uid',
          () async {
        // Arrange
        const uid = 'widget-subscription-99';

        // Act
        await dataSource.stopSubscription(uid);

        // Assert
        expect(
          fakeApiManager.calledMethods,
          contains('stopWebsocketSubscription'),
        );
        expect(fakeApiManager.lastStoppedUid, uid);
      });

      test('should complete without error when called with any uid string',
          () async {
        // Arrange
        const uid = 'some-uid-that-never-existed';

        // Act & Assert
        await expectLater(
          dataSource.stopSubscription(uid),
          completes,
        );
      });

      test('should be idempotent when called twice with the same uid', () async {
        // Arrange
        const uid = 'idempotent-uid';

        // Act
        await dataSource.stopSubscription(uid);
        await dataSource.stopSubscription(uid);

        // Assert
        final stopCalls = fakeApiManager.calledMethods
            .where((m) => m == 'stopWebsocketSubscription')
            .length;
        expect(stopCalls, 2);
        expect(fakeApiManager.lastStoppedUid, uid);
      });
    });

    // -----------------------------------------------------------------------
    group('subscription lifecycle', () {
      test('should start then stop a subscription without error', () async {
        // Arrange
        final subscription = FakeDirectusWebSocketSubscription(
          uid: 'lifecycle-sub',
        );

        // Act
        await dataSource.startSubscription(subscription);
        await dataSource.stopSubscription(subscription.uid);

        // Assert
        expect(
          fakeApiManager.calledMethods,
          containsAllInOrder([
            'startWebsocketSubscription',
            'stopWebsocketSubscription',
          ]),
        );
      });

      test('should support multiple distinct subscriptions started in sequence',
          () async {
        // Arrange
        final sub1 = FakeDirectusWebSocketSubscription(uid: 'sub-a');
        final sub2 = FakeDirectusWebSocketSubscription(uid: 'sub-b');

        // Act
        await dataSource.startSubscription(sub1);
        await dataSource.startSubscription(sub2);

        // Assert
        final starts = fakeApiManager.calledMethods
            .where((m) => m == 'startWebsocketSubscription')
            .length;
        expect(starts, 2);
      });
    });
  });
}
