import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';

/// Repository interface for tracking user presence on menu editing sessions.
abstract class PresenceRepository {
  /// Register that a user has joined a menu editing session.
  Future<Result<void, DomainError>> joinMenu(int menuId, String userId);

  /// Register that a user has left a menu editing session.
  Future<Result<void, DomainError>> leaveMenu(int menuId, String userId);

  /// Update the heartbeat timestamp for a user on a menu.
  Future<Result<void, DomainError>> heartbeat(int menuId, String userId);

  /// Get all active users currently editing a menu.
  Future<Result<List<MenuPresence>, DomainError>> getActiveUsers(int menuId);
}
