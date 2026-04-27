import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_presence.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/features/collaboration/presentation/widgets/presence_bar.dart';

void main() {
  Widget buildWidget({
    required List<MenuPresence> presences,
    String currentUserId = 'user-1',
  }) {
    return ProviderScope(
      overrides: [
        directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
        directusAccessTokenProvider.overrideWithValue('test-token'),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: PresenceBar(presences: presences, currentUserId: currentUserId),
        ),
      ),
    );
  }

  group('PresenceBar', () {
    testWidgets('should display nothing when presences list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(presences: []));

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

      await tester.pumpWidget(buildWidget(presences: presences));

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

      await tester.pumpWidget(buildWidget(presences: presences));

      // Only 1 avatar (current user excluded)
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should show initials in avatar when no userAvatar', (
      tester,
    ) async {
      final presences = [
        MenuPresence(
          id: 1,
          userId: 'user-2',
          menuId: 42,
          lastSeen: DateTime.now(),
          userName: 'Alice Baker',
        ),
      ];

      await tester.pumpWidget(buildWidget(presences: presences));

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

      await tester.pumpWidget(buildWidget(presences: presences));

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

      await tester.pumpWidget(buildWidget(presences: presences));

      // Only active user shown
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should show avatar image when userAvatar is non-null', (
      tester,
    ) async {
      const avatarUuid = 'avatar-uuid-789';
      final presences = [
        MenuPresence(
          id: 1,
          userId: 'user-2',
          menuId: 42,
          lastSeen: DateTime.now(),
          userName: 'Alice Baker',
          userAvatar: avatarUuid,
        ),
      ];

      await tester.pumpWidget(buildWidget(presences: presences));

      final image = tester.widget<Image>(find.byType(Image));
      final networkImage = image.image as NetworkImage;
      expect(networkImage.url, 'http://localhost:8055/assets/$avatarUuid');
      expect(
        networkImage.headers,
        containsPair('Authorization', 'Bearer test-token'),
      );
    });

    testWidgets('should show initials as fallback when userAvatar is null', (
      tester,
    ) async {
      final presences = [
        MenuPresence(
          id: 1,
          userId: 'user-2',
          menuId: 42,
          lastSeen: DateTime.now(),
          userName: 'Alice Baker',
        ),
      ];

      await tester.pumpWidget(buildWidget(presences: presences));

      expect(find.text('AB'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
