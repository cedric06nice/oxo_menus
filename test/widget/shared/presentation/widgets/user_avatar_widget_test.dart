import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/shared/presentation/widgets/user_avatar_widget.dart';

void main() {
  group('UserAvatarWidget', () {
    Widget buildWidget(User? user, {double radius = 20.0}) {
      return ProviderScope(
        overrides: [
          directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
          directusAccessTokenProvider.overrideWithValue('test-token'),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: UserAvatarWidget(user: user, radius: radius),
          ),
        ),
      );
    }

    testWidgets('should show person icon when user is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildWidget(null));

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should show initials when user has first and last name', (
      WidgetTester tester,
    ) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
      );

      await tester.pumpWidget(buildWidget(user));

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should show first initial only when no last name', (
      WidgetTester tester,
    ) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
      );

      await tester.pumpWidget(buildWidget(user));

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('should show email initial when no first name', (
      WidgetTester tester,
    ) async {
      const user = User(id: 'user-1', email: 'john@example.com');

      await tester.pumpWidget(buildWidget(user));

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('should show email initial when first name is empty', (
      WidgetTester tester,
    ) async {
      const user = User(id: 'user-1', email: 'test@example.com', firstName: '');

      await tester.pumpWidget(buildWidget(user));

      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('should use custom radius', (WidgetTester tester) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
      );

      await tester.pumpWidget(buildWidget(user, radius: 30.0));

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 30.0);
    });

    testWidgets('should show initials when avatar URL is empty string', (
      WidgetTester tester,
    ) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: '',
      );

      await tester.pumpWidget(buildWidget(user));

      expect(find.text('JD'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('should build asset URL from base URL and avatar UUID', (
      WidgetTester tester,
    ) async {
      const avatarUuid = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: avatarUuid,
      );

      await tester.pumpWidget(buildWidget(user));

      final image = tester.widget<Image>(find.byType(Image));
      final networkImage = image.image as NetworkImage;
      expect(networkImage.url, 'http://localhost:8055/assets/$avatarUuid');
    });

    testWidgets('should pass Authorization header to Image.network', (
      WidgetTester tester,
    ) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'some-file-uuid',
      );

      await tester.pumpWidget(buildWidget(user));

      final image = tester.widget<Image>(find.byType(Image));
      final networkImage = image.image as NetworkImage;
      expect(
        networkImage.headers,
        containsPair('Authorization', 'Bearer test-token'),
      );
    });

    testWidgets('should not pass auth headers when token is null', (
      WidgetTester tester,
    ) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'some-file-uuid',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
            directusAccessTokenProvider.overrideWithValue(null),
          ],
          child: const MaterialApp(
            home: Scaffold(body: UserAvatarWidget(user: user)),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final networkImage = image.image as NetworkImage;
      expect(networkImage.headers, isNull);
    });
  });
}
