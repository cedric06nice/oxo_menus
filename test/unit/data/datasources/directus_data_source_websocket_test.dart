import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/data/datasources/directus_data_source.dart';
import 'package:oxo_menus/data/datasources/secure_token_storage.dart';
import 'package:oxo_menus/data/models/widget_dto.dart';

class MockDirectusApiManager extends Mock implements DirectusApiManager {}

class MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

class FakeDirectusWebSocketSubscription extends Fake
    implements DirectusWebSocketSubscription<WidgetDto> {
  @override
  final String uid = 'test-uid-123';
}

void main() {
  group('DirectusDataSource WebSocket methods', () {
    late MockDirectusApiManager mockApiManager;
    late MockSecureTokenStorage mockTokenStorage;
    late DirectusDataSource dataSource;

    setUp(() {
      mockApiManager = MockDirectusApiManager();
      mockTokenStorage = MockSecureTokenStorage();
      dataSource = DirectusDataSource(
        baseUrl: 'http://localhost:8055',
        apiManager: mockApiManager,
        tokenStorage: mockTokenStorage,
      );
    });

    group('startSubscription', () {
      test(
        'should delegate to apiManager.startWebsocketSubscription',
        () async {
          final subscription = FakeDirectusWebSocketSubscription();
          when(
            () => mockApiManager.startWebsocketSubscription(subscription),
          ).thenAnswer((_) async {});

          await dataSource.startSubscription(subscription);

          verify(
            () => mockApiManager.startWebsocketSubscription(subscription),
          ).called(1);
        },
      );
    });

    group('stopSubscription', () {
      test('should delegate to apiManager.stopWebsocketSubscription', () async {
        when(
          () => mockApiManager.stopWebsocketSubscription('test-uid-123'),
        ).thenAnswer((_) async {});

        await dataSource.stopSubscription('test-uid-123');

        verify(
          () => mockApiManager.stopWebsocketSubscription('test-uid-123'),
        ).called(1);
      });
    });
  });
}
