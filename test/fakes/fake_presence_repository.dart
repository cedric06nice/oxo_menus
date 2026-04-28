import 'dart:async';

import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_presence.dart';
import 'package:oxo_menus/features/collaboration/domain/repositories/presence_repository.dart';

// ---------------------------------------------------------------------------
// Call-record types
// ---------------------------------------------------------------------------

/// Sealed union of every recorded call on [FakePresenceRepository].
sealed class PresenceCall {
  const PresenceCall();
}

final class JoinMenuCall extends PresenceCall {
  final int menuId;
  final String userId;
  final String? userName;
  final String? userAvatar;
  const JoinMenuCall({
    required this.menuId,
    required this.userId,
    this.userName,
    this.userAvatar,
  });
}

final class LeaveMenuCall extends PresenceCall {
  final int menuId;
  final String userId;
  const LeaveMenuCall({required this.menuId, required this.userId});
}

final class HeartbeatCall extends PresenceCall {
  final int menuId;
  final String userId;
  const HeartbeatCall({required this.menuId, required this.userId});
}

final class GetActiveUsersCall extends PresenceCall {
  final int menuId;
  const GetActiveUsersCall({required this.menuId});
}

final class WatchActiveUsersCall extends PresenceCall {
  final int menuId;
  const WatchActiveUsersCall({required this.menuId});
}

final class UnsubscribePresenceCall extends PresenceCall {
  final int menuId;
  const UnsubscribePresenceCall({required this.menuId});
}

// ---------------------------------------------------------------------------
// FakePresenceRepository
// ---------------------------------------------------------------------------

/// A fully manual fake for [PresenceRepository].
///
/// Future methods (joinMenu, leaveMenu, heartbeat, getActiveUsers,
/// unsubscribePresence) each have a dedicated stub setter.  When unset,
/// they throw [StateError].
///
/// [watchActiveUsers] is stream-based: an internal per-menu
/// [StreamController] is managed so tests can drive events.
///
/// Usage:
/// ```dart
/// final fake = FakePresenceRepository();
/// fake.whenJoinMenu(success(null));
/// fake.whenGetActiveUsers(42, success([presence]));
/// final stream = fake.watchActiveUsers(42);
/// fake.emitPresence(42, [presence]);
/// ```
class FakePresenceRepository implements PresenceRepository {
  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<PresenceCall> calls = [];

  // -------------------------------------------------------------------------
  // Response stubs for Future methods
  // -------------------------------------------------------------------------

  Result<void, DomainError>? _joinMenuResult;
  Result<void, DomainError>? _leaveMenuResult;
  Result<void, DomainError>? _heartbeatResult;

  // Per-menu getActiveUsers stubs.  Falls back to _getActiveUsersDefaultResult
  // when a per-menu stub is absent.
  final Map<int, Result<List<MenuPresence>, DomainError>>
  _getActiveUsersResults = {};
  Result<List<MenuPresence>, DomainError>? _getActiveUsersDefaultResult;

  // -------------------------------------------------------------------------
  // Response setters — Future methods
  // -------------------------------------------------------------------------

  /// Configures all joinMenu calls to return [result].
  void whenJoinMenu(Result<void, DomainError> result) {
    _joinMenuResult = result;
  }

  /// Configures all leaveMenu calls to return [result].
  void whenLeaveMenu(Result<void, DomainError> result) {
    _leaveMenuResult = result;
  }

  /// Configures all heartbeat calls to return [result].
  void whenHeartbeat(Result<void, DomainError> result) {
    _heartbeatResult = result;
  }

  /// Configures [getActiveUsers] for a specific [menuId] to return [result].
  void whenGetActiveUsers(
    int menuId,
    Result<List<MenuPresence>, DomainError> result,
  ) {
    _getActiveUsersResults[menuId] = result;
  }

  /// Configures a default [getActiveUsers] result used when no per-menu stub
  /// is set.
  void whenGetActiveUsersDefault(
    Result<List<MenuPresence>, DomainError> result,
  ) {
    _getActiveUsersDefaultResult = result;
  }

  // -------------------------------------------------------------------------
  // Stream drivers — watchActiveUsers
  // -------------------------------------------------------------------------

  final Map<int, StreamController<List<MenuPresence>>> _presenceControllers =
      {};

  /// Pushes [users] to the presence stream for [menuId].
  void emitPresence(int menuId, List<MenuPresence> users) {
    _presenceControllerFor(menuId).add(users);
  }

  /// Closes the presence stream for [menuId].
  void closePresenceStream(int menuId) {
    _presenceControllerFor(menuId).close();
  }

  /// Adds an error to the presence stream for [menuId].
  void addPresenceError(int menuId, Object error) {
    _presenceControllerFor(menuId).addError(error);
  }

  // -------------------------------------------------------------------------
  // Convenience call-count helpers
  // -------------------------------------------------------------------------

  List<JoinMenuCall> get joinMenuCalls =>
      calls.whereType<JoinMenuCall>().toList();

  List<LeaveMenuCall> get leaveMenuCalls =>
      calls.whereType<LeaveMenuCall>().toList();

  List<HeartbeatCall> get heartbeatCalls =>
      calls.whereType<HeartbeatCall>().toList();

  List<GetActiveUsersCall> get getActiveUsersCalls =>
      calls.whereType<GetActiveUsersCall>().toList();

  List<WatchActiveUsersCall> get watchActiveUsersCalls =>
      calls.whereType<WatchActiveUsersCall>().toList();

  List<UnsubscribePresenceCall> get unsubscribePresenceCalls =>
      calls.whereType<UnsubscribePresenceCall>().toList();

  // -------------------------------------------------------------------------
  // PresenceRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<Result<void, DomainError>> joinMenu(
    int menuId,
    String userId, {
    String? userName,
    String? userAvatar,
  }) async {
    calls.add(
      JoinMenuCall(
        menuId: menuId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
      ),
    );
    if (_joinMenuResult != null) {
      return _joinMenuResult!;
    }
    throw StateError(
      'FakePresenceRepository: no response configured for joinMenu()',
    );
  }

  @override
  Future<Result<void, DomainError>> leaveMenu(int menuId, String userId) async {
    calls.add(LeaveMenuCall(menuId: menuId, userId: userId));
    if (_leaveMenuResult != null) {
      return _leaveMenuResult!;
    }
    throw StateError(
      'FakePresenceRepository: no response configured for leaveMenu()',
    );
  }

  @override
  Future<Result<void, DomainError>> heartbeat(int menuId, String userId) async {
    calls.add(HeartbeatCall(menuId: menuId, userId: userId));
    if (_heartbeatResult != null) {
      return _heartbeatResult!;
    }
    throw StateError(
      'FakePresenceRepository: no response configured for heartbeat()',
    );
  }

  @override
  Future<Result<List<MenuPresence>, DomainError>> getActiveUsers(
    int menuId,
  ) async {
    calls.add(GetActiveUsersCall(menuId: menuId));
    if (_getActiveUsersResults.containsKey(menuId)) {
      return _getActiveUsersResults[menuId]!;
    }
    if (_getActiveUsersDefaultResult != null) {
      return _getActiveUsersDefaultResult!;
    }
    throw StateError(
      'FakePresenceRepository: no response configured for getActiveUsers($menuId)',
    );
  }

  @override
  Stream<List<MenuPresence>> watchActiveUsers(int menuId) {
    calls.add(WatchActiveUsersCall(menuId: menuId));
    return _presenceControllerFor(menuId).stream;
  }

  @override
  Future<void> unsubscribePresence(int menuId) async {
    calls.add(UnsubscribePresenceCall(menuId: menuId));
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  StreamController<List<MenuPresence>> _presenceControllerFor(int menuId) {
    if (!_presenceControllers.containsKey(menuId)) {
      _presenceControllers[menuId] =
          StreamController<List<MenuPresence>>.broadcast();
    }
    return _presenceControllers[menuId]!;
  }

  /// Disposes all open stream controllers.  Call from [tearDown] when
  /// resource clean-up matters.
  void dispose() {
    for (final controller in _presenceControllers.values) {
      controller.close();
    }
    _presenceControllers.clear();
  }
}
