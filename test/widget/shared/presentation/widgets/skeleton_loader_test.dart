import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/presentation/widgets/skeleton_loader.dart';

void main() {
  group('SkeletonCard', () {
    testWidgets('renders a container with animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonCard())),
      );

      expect(find.byType(SkeletonCard), findsOneWidget);
      expect(find.byType(AnimatedOpacity), findsOneWidget);
    });
  });

  group('SkeletonGrid', () {
    testWidgets('renders specified number of skeleton cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonGrid(itemCount: 4))),
      );

      expect(find.byType(SkeletonCard), findsNWidgets(4));
    });

    testWidgets('defaults to 6 items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonGrid())),
      );

      expect(find.byType(SkeletonCard), findsNWidgets(6));
    });
  });
}
