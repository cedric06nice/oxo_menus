import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/data/models/menu_dto.dart';
import 'package:oxo_menus/data/models/page_dto.dart';

import 'fake_directus_data_source.dart';
import 'fake_directus_websocket_subscription.dart';

void main() {
  group('FakeDirectusDataSource', () {
    late FakeDirectusDataSource fake;

    setUp(() {
      fake = FakeDirectusDataSource();
    });

    // -------------------------------------------------------------------------
    // Call recording
    // -------------------------------------------------------------------------

    group('call recording', () {
      test('should record a LoginCall when login() is called', () async {
        // Arrange
        fake.whenLogin({'user': {}, 'access_token': 'tok', 'refresh_token': 'ref'});

        // Act
        await fake.login(email: 'a@b.com', password: 'secret');

        // Assert
        expect(fake.calls, hasLength(1));
        expect(fake.calls.first, isA<LoginCall>());
      });

      test('should capture email and password in LoginCall', () async {
        // Arrange
        fake.whenLogin({});

        // Act
        await fake.login(email: 'chef@restaurant.com', password: 'pass123');

        // Assert
        final call = fake.calls.first as LoginCall;
        expect(call.email, equals('chef@restaurant.com'));
        expect(call.password, equals('pass123'));
      });

      test('should record a LogoutCall when logout() is called', () async {
        // Act
        await fake.logout();

        // Assert
        expect(fake.calls, hasLength(1));
        expect(fake.calls.first, isA<LogoutCall>());
      });

      test('should record a GetItemsCall with itemType when getItems is called', () async {
        // Arrange
        fake.whenGetItems<MenuDto>([]);

        // Act
        await fake.getItems<MenuDto>();

        // Assert
        expect(fake.calls, hasLength(1));
        final call = fake.calls.first as GetItemsCall;
        expect(call.itemType, equals(MenuDto));
      });

      test('should record filter in GetItemsCall', () async {
        // Arrange
        fake.whenGetItems<MenuDto>([]);
        final filter = {'status': {'_eq': 'published'}};

        // Act
        await fake.getItems<MenuDto>(filter: filter);

        // Assert
        final call = fake.calls.first as GetItemsCall;
        expect(call.filter, equals(filter));
      });

      test('should record a StartSubscriptionCall when startSubscription is called', () async {
        // Arrange
        final subscription = FakeDirectusWebSocketSubscription(uid: 'sub-1');

        // Act
        await fake.startSubscription(subscription);

        // Assert
        expect(fake.calls, hasLength(1));
        final call = fake.calls.first as StartSubscriptionCall;
        expect(call.subscription, same(subscription));
      });

      test('should accumulate multiple calls in order', () async {
        // Arrange
        fake.whenGetItems<MenuDto>([]);
        fake.whenGetItems<PageDto>([]);

        // Act
        await fake.getItems<MenuDto>();
        await fake.logout();
        await fake.getItems<PageDto>();

        // Assert
        expect(fake.calls, hasLength(3));
        expect(fake.calls[0], isA<GetItemsCall>());
        expect(fake.calls[1], isA<LogoutCall>());
        expect(fake.calls[2], isA<GetItemsCall>());
      });
    });

    // -------------------------------------------------------------------------
    // Preset responses
    // -------------------------------------------------------------------------

    group('preset responses', () {
      test('should return configured login response', () async {
        // Arrange
        final response = {'user': {'id': 'u1'}, 'access_token': 'at', 'refresh_token': 'rt'};
        fake.whenLogin(response);

        // Act
        final result = await fake.login(email: 'x@y.com', password: 'p');

        // Assert
        expect(result, equals(response));
      });

      test('should return configured getItems response', () async {
        // Arrange
        final items = [
          {'id': 1, 'name': 'Dinner Menu'},
          {'id': 2, 'name': 'Lunch Menu'},
        ];
        fake.whenGetItems<MenuDto>(items);

        // Act
        final result = await fake.getItems<MenuDto>();

        // Assert
        expect(result, equals(items));
      });

      test('should return configured uploadFile result', () async {
        // Arrange
        fake.whenUploadFile('file-uuid-123');

        // Act
        final fileId = await fake.uploadFile(Uint8List(0), 'menu.pdf');

        // Assert
        expect(fileId, equals('file-uuid-123'));
      });

      test('should return configured downloadFileBytes result', () async {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3]);
        fake.whenDownloadFileBytes(bytes);

        // Act
        final result = await fake.downloadFileBytes('file-abc');

        // Assert
        expect(result, equals(bytes));
      });

      test('should return configured tryRestoreSession result', () async {
        // Arrange
        fake.whenTryRestoreSession(true);

        // Act
        final restored = await fake.tryRestoreSession();

        // Assert
        expect(restored, isTrue);
      });

      test('should complete deleteItem without error when configured', () async {
        // Arrange
        fake.whenDeleteItem<MenuDto>();

        // Act / Assert — no exception thrown
        await expectLater(
          fake.deleteItem<MenuDto>(42),
          completes,
        );
      });
    });

    // -------------------------------------------------------------------------
    // Configured error paths
    // -------------------------------------------------------------------------

    group('configured errors', () {
      test('should throw configured login error', () async {
        // Arrange
        fake.whenLoginThrows(Exception('connection refused'));

        // Act / Assert
        await expectLater(
          fake.login(email: 'x@y.com', password: 'p'),
          throwsException,
        );
      });

      test('should throw configured getItems error for a specific DTO type', () async {
        // Arrange
        fake.whenGetItemsThrows<MenuDto>(Exception('server error'));

        // Act / Assert
        await expectLater(
          fake.getItems<MenuDto>(),
          throwsException,
        );
      });

      test('should throw configured uploadFile error', () async {
        // Arrange
        fake.whenUploadFileThrows(Exception('unauthorized'));

        // Act / Assert
        await expectLater(
          fake.uploadFile(Uint8List(0), 'file.pdf'),
          throwsException,
        );
      });
    });

    // -------------------------------------------------------------------------
    // Unconfigured method → StateError
    // -------------------------------------------------------------------------

    group('unconfigured methods throw StateError', () {
      test('should throw StateError when login is called without configuration', () async {
        // Act / Assert
        await expectLater(
          fake.login(email: 'x@y.com', password: 'p'),
          throwsStateError,
        );
      });

      test('should throw StateError when getItems is called without configuration', () async {
        // Act / Assert
        await expectLater(
          fake.getItems<MenuDto>(),
          throwsStateError,
        );
      });

      test('should throw StateError when getItem is called without configuration', () async {
        // Act / Assert
        await expectLater(
          fake.getItem<MenuDto>(1),
          throwsStateError,
        );
      });

      test('should throw StateError when getCurrentUser is called without configuration', () async {
        // Act / Assert
        await expectLater(
          fake.getCurrentUser(),
          throwsStateError,
        );
      });

      test('should throw StateError when uploadFile is called without configuration', () async {
        // Act / Assert
        await expectLater(
          fake.uploadFile(Uint8List(0), 'x.pdf'),
          throwsStateError,
        );
      });

      test('should throw StateError when downloadFileBytes is called without configuration', () async {
        // Act / Assert
        await expectLater(
          fake.downloadFileBytes('file-id'),
          throwsStateError,
        );
      });

      test('should throw StateError when deleteItem is called without configuration', () async {
        // Act / Assert
        await expectLater(
          fake.deleteItem<MenuDto>(1),
          throwsStateError,
        );
      });
    });

    // -------------------------------------------------------------------------
    // Type-scoped stubs
    // -------------------------------------------------------------------------

    group('type-scoped stubs do not cross type boundaries', () {
      test('should not serve MenuDto response for PageDto request', () async {
        // Arrange — only configure MenuDto
        fake.whenGetItems<MenuDto>([]);

        // Act / Assert — PageDto is unconfigured → StateError
        await expectLater(
          fake.getItems<PageDto>(),
          throwsStateError,
        );
      });
    });

    // -------------------------------------------------------------------------
    // Convenience call-count helpers
    // -------------------------------------------------------------------------

    group('call-count helpers', () {
      test('should return correct count from getItemsCalls<T>()', () async {
        // Arrange
        fake.whenGetItems<MenuDto>([]);
        fake.whenGetItems<PageDto>([]);

        // Act
        await fake.getItems<MenuDto>();
        await fake.getItems<MenuDto>(filter: {'status': {'_eq': 'draft'}});
        await fake.getItems<PageDto>();

        // Assert
        expect(fake.getItemsCalls<MenuDto>(), hasLength(2));
        expect(fake.getItemsCalls<PageDto>(), hasLength(1));
      });
    });
  });
}
