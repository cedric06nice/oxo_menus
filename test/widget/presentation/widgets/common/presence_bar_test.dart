import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_presence.dart';
import 'package:oxo_menus/presentation/widgets/common/presence_bar.dart';

void main() {
  group('PresenceBar', () {
    testWidgets('should display nothing when presences list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PresenceBar(presences: [], currentUserId: 'user-1'),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsNothing);
    });

    testWidgets('should display avatar chips for other users', (tester) async {
      final presences = [
        MenuPresence(
          id: 1,
          userId: 'user-2',
          menuId: 42,
          lastSeen: DateTime.now(),
          userName: 'Alice',
        ),
        MenuPresence(
          id: 2,
          userId: 'user-3',
          menuId: 42,
          lastSeen: DateTime.now(),
          userName: 'Bob',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PresenceBar(presences: presences, currentUserId: 'user-1'),
          ),
        ),
      );

      // Should show 2 avatars (both are other users)
      expect(find.byType(CircleAvatar), findsNWidgets(2));
    });

    testWidgets('should exclude the current user from display', (tester) async {
      final presences = [
        MenuPresence(
          id: 1,
          userId: 'user-1',
          menuId: 42,
          lastSeen: DateTime.now(),
          userName: 'Me',
        ),
        MenuPresence(
          id: 2,
          userId: 'user-2',
          menuId: 42,
          lastSeen: DateTime.now(),
          userName: 'Alice',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PresenceBar(presences: presences, currentUserId: 'user-1'),
          ),
        ),
      );

      // Only 1 avatar (current user excluded)
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should show initials in avatar', (tester) async {
      final presences = [
        MenuPresence(
          id: 1,
          userId: 'user-2',
          menuId: 42,
          lastSeen: DateTime.now(),
          userName: 'Alice Baker',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PresenceBar(presences: presences, currentUserId: 'user-1'),
          ),
        ),
      );

      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('should show tooltip with user name', (tester) async {
      final presences = [
        MenuPresence(
          id: 1,
          userId: 'user-2',
          menuId: 42,
          lastSeen: DateTime.now(),
          userName: 'Alice',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PresenceBar(presences: presences, currentUserId: 'user-1'),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('should filter out stale presences (>2 min)', (tester) async {
      final presences = [
        MenuPresence(
          id: 1,
          userId: 'user-2',
          menuId: 42,
          lastSeen: DateTime.now().subtract(const Duration(minutes: 3)),
          userName: 'Stale User',
        ),
        MenuPresence(
          id: 2,
          userId: 'user-3',
          menuId: 42,
          lastSeen: DateTime.now(),
          userName: 'Active User',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PresenceBar(presences: presences, currentUserId: 'user-1'),
          ),
        ),
      );

      // Only active user shown
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });
}
