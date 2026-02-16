import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/user.dart';
import 'package:oxo_menus/presentation/widgets/common/user_avatar_widget.dart';

void main() {
  group('UserAvatarWidget', () {
    testWidgets('should show person icon when user is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserAvatarWidget(user: null)),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should show initials when user has first and last name',
        (WidgetTester tester) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserAvatarWidget(user: user)),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should show first initial only when no last name',
        (WidgetTester tester) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserAvatarWidget(user: user)),
        ),
      );

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('should show email initial when no first name',
        (WidgetTester tester) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserAvatarWidget(user: user)),
        ),
      );

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('should show email initial when first name is empty',
        (WidgetTester tester) async {
      const user = User(
        id: 'user-1',
        email: 'test@example.com',
        firstName: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserAvatarWidget(user: user)),
        ),
      );

      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('should use custom radius', (WidgetTester tester) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserAvatarWidget(user: user, radius: 30.0)),
        ),
      );

      final avatar =
          tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 30.0);
    });

    testWidgets('should attempt to show network image when avatar URL exists',
        (WidgetTester tester) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'https://example.com/avatar.png',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserAvatarWidget(user: user)),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should show initials when avatar URL is empty string',
        (WidgetTester tester) async {
      const user = User(
        id: 'user-1',
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UserAvatarWidget(user: user)),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
