import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';

import 'fake_presence_repository.dart';
import 'result_helpers.dart';

void main() {
  group('FakePresenceRepository', () {
    late FakePresenceRepository fake;

    setUp(() {
      fake = FakePresenceRepository();
    });

    tearDown(() {
      fake.dispose();
    });

    // -----------------------------------------------------------------------
    // Default state — unset methods throw StateError
    // -----------------------------------------------------------------------

    group('default state', () {
      test(
        'should throw StateError when joinMenu is called without configuration',
        () async {
          // Act / Assert
          await expectLater(
            fake.joinMenu(1, 'user-1'),
            throwsStateError,
          );
        },
      );

      test(
        'should throw StateError when leaveMenu is called without configuration',
        () async {
          // Act / Assert
          await expectLater(
            fake.leaveMenu(1, 'user-1'),
            throwsStateError,
          );
        },
      );

      test(
        'should throw StateError when heartbeat is called without configuration',
        () async {
          // Act / Assert
          await expectLater(
            fake.heartbeat(1, 'user-1'),
            throwsStateError,
          );
        },
      );

      test(
        'should throw StateError when getActiveUsers is called without configuration',
        () async {
          // Act / Assert
          await expectLater(
            fake.getActiveUsers(1),
            throwsStateError,
          );
        },
      );

      test(
        'should complete without error when unsubscribePresence is called without configuration',
        () async {
          // Act / Assert
          await expectLater(fake.unsubscribePresence(1), completes);
        },
      );
    });

    // -----------------------------------------------------------------------
    // Preset responses — Future methods
    // -----------------------------------------------------------------------

    group('preset responses', () {
      test(
        'should return configured Success when joinMenu is called after whenJoinMenu',
        () async {
          // Arrange
          fake.whenJoinMenu(success(null));

          // Act
          final result = await fake.joinMenu(1, 'user-1');

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test(
        'should return configured Failure when joinMenu is called after whenJoinMenu with failure',
        () async {
          // Arrange
          fake.whenJoinMenu(failure<void>(network()));

          // Act
          final result = await fake.joinMenu(1, 'user-1');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.errorOrNull, isA<NetworkError>());
        },
      );

      test(
        'should return configured Success when leaveMenu is called after whenLeaveMenu',
        () async {
          // Arrange
          fake.whenLeaveMenu(success(null));

          // Act
          final result = await fake.leaveMenu(2, 'user-1');

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test(
        'should return configured Success when heartbeat is called after whenHeartbeat',
        () async {
          // Arrange
          fake.whenHeartbeat(success(null));

          // Act
          final result = await fake.heartbeat(3, 'user-1');

          // Assert
          expect(result.isSuccess, isTrue);
        },
      );

      test(
        'should return per-menu result when getActiveUsers is called for a configured menuId',
        () async {
          // Arrange
          final presence = MenuPresence(
            id: 1,
            userId: 'user-42',
            menuId: 7,
            lastSeen: DateTime(2024, 1, 1),
          );
          fake.whenGetActiveUsers(7, success([presence]));

          // Act
          final result = await fake.getActiveUsers(7);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, hasLength(1));
          expect(result.valueOrNull!.first.userId, equals('user-42'));
        },
      );

      test(
        'should return default result when getActiveUsers is called for an unconfigured menuId',
        () async {
          // Arrange
          fake.whenGetActiveUsersDefault(success([]));

          // Act
          final result = await fake.getActiveUsers(99);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.valueOrNull, isEmpty);
        },
      );

      test(
        'should throw StateError when getActiveUsers menuId is unconfigured and no default is set',
        () async {
          // Arrange — configure only menu 5, not menu 6
          fake.whenGetActiveUsers(5, success([]));

          // Act / Assert
          await expectLater(
            fake.getActiveUsers(6),
            throwsStateError,
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // Call recording
    // -----------------------------------------------------------------------

    group('call recording', () {
      test(
        'should record a JoinMenuCall with menuId and userId when joinMenu is called',
        () async {
          // Arrange
          fake.whenJoinMenu(success(null));

          // Act
          await fake.joinMenu(42, 'user-7', userName: 'Chef', userAvatar: null);

          // Assert
          expect(fake.joinMenuCalls, hasLength(1));
          final call = fake.joinMenuCalls.first;
          expect(call.menuId, equals(42));
          expect(call.userId, equals('user-7'));
          expect(call.userName, equals('Chef'));
        },
      );

      test(
        'should record a LeaveMenuCall with correct arguments',
        () async {
          // Arrange
          fake.whenLeaveMenu(success(null));

          // Act
          await fake.leaveMenu(10, 'user-3');

          // Assert
          expect(fake.leaveMenuCalls, hasLength(1));
          expect(fake.leaveMenuCalls.first.menuId, equals(10));
          expect(fake.leaveMenuCalls.first.userId, equals('user-3'));
        },
      );

      test(
        'should record a HeartbeatCall with correct arguments',
        () async {
          // Arrange
          fake.whenHeartbeat(success(null));

          // Act
          await fake.heartbeat(5, 'user-99');

          // Assert
          expect(fake.heartbeatCalls, hasLength(1));
          expect(fake.heartbeatCalls.first.menuId, equals(5));
          expect(fake.heartbeatCalls.first.userId, equals('user-99'));
        },
      );

      test(
        'should record a WatchActiveUsersCall with correct menuId',
        () {
          // Act
          fake.watchActiveUsers(8);

          // Assert
          expect(fake.watchActiveUsersCalls, hasLength(1));
          expect(fake.watchActiveUsersCalls.first.menuId, equals(8));
        },
      );

      test(
        'should record an UnsubscribePresenceCall when unsubscribePresence is called',
        () async {
          // Act
          await fake.unsubscribePresence(13);

          // Assert
          expect(fake.unsubscribePresenceCalls, hasLength(1));
          expect(fake.unsubscribePresenceCalls.first.menuId, equals(13));
        },
      );
    });

    // -----------------------------------------------------------------------
    // Stream delivery via emitPresence
    // -----------------------------------------------------------------------

    group('stream delivery', () {
      test(
        'should deliver emitted presence list to a watchActiveUsers listener',
        () async {
          // Arrange
          final stream = fake.watchActiveUsers(20);
          final presence = MenuPresence(
            id: 1,
            userId: 'user-1',
            menuId: 20,
            lastSeen: DateTime(2024, 6, 1),
          );

          // Act
          final future = stream.first;
          fake.emitPresence(20, [presence]);

          // Assert
          final received = await future;
          expect(received, hasLength(1));
          expect(received.first.userId, equals('user-1'));
        },
      );

      test(
        'should not deliver events emitted for a different menuId',
        () async {
          // Arrange
          final stream = fake.watchActiveUsers(1);
          final received = <List<MenuPresence>>[];
          final subscription = stream.listen(received.add);

          // Act — emit on menu 2, not menu 1
          fake.emitPresence(2, []);
          await Future<void>.delayed(Duration.zero);
          await subscription.cancel();

          // Assert
          expect(received, isEmpty);
        },
      );

      test(
        'should close the presence stream when closePresenceStream is called',
        () async {
          // Arrange
          final stream = fake.watchActiveUsers(4);

          // Act / Assert — stream should complete
          final future = stream.toList();
          fake.closePresenceStream(4);
          final items = await future;
          expect(items, isEmpty);
        },
      );
    });
  });
}
