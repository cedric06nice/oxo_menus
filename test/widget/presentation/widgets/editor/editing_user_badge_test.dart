import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/editor/editing_user_badge.dart';

void main() {
  Widget buildWidget({String? userName, String? userAvatar}) {
    return ProviderScope(
      overrides: [
        directusBaseUrlProvider.overrideWithValue('http://localhost:8055'),
        directusAccessTokenProvider.overrideWithValue('test-token'),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: EditingUserBadge(userName: userName, userAvatar: userAvatar),
        ),
      ),
    );
  }

  group('EditingUserBadge', () {
    testWidgets('should show initials when userName provided and no avatar', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(userName: 'Alice Baker'));

      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('should show "?" when userName is null', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should show avatar image when userAvatar is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(userName: 'Alice Baker', userAvatar: 'avatar-uuid-123'),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final networkImage = image.image as NetworkImage;
      expect(networkImage.url, 'http://localhost:8055/assets/avatar-uuid-123');
      expect(
        networkImage.headers,
        containsPair('Authorization', 'Bearer test-token'),
      );
    });

    testWidgets('should show edit icon', (tester) async {
      await tester.pumpWidget(buildWidget(userName: 'Alice'));

      // Platform-adaptive: either pencil or edit icon
      expect(
        find.byIcon(CupertinoIcons.pencil).evaluate().isNotEmpty ||
            find.byIcon(Icons.edit).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should show Tooltip with user name', (tester) async {
      await tester.pumpWidget(buildWidget(userName: 'Alice Baker'));

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Alice Baker');
    });
  });
}
