import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/menu/domain/entities/widget_instance.dart';
import 'package:oxo_menus/features/menu/presentation/widgets/canvas/widget_renderer.dart';

void main() {
  group('WidgetRenderer', () {
    final testWidget = WidgetInstance(
      id: 1,
      type: 'section',
      version: '1.0.0',
      props: {'title': 'Test Section'},
      index: 0,
      columnId: 1,
    );

    testWidgets('passes onEditStarted and onEditEnded to WidgetContext', (
      tester,
    ) async {
      var editStartedCalled = false;
      var editEndedCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WidgetRenderer(
                widgetInstance: testWidget,
                isEditable: true,
                onEditStarted: () => editStartedCalled = true,
                onEditEnded: () => editEndedCalled = true,
              ),
            ),
          ),
        ),
      );

      // Tap to open edit dialog — SectionWidget uses GestureDetector on tap
      await tester.tap(find.text('Test Section'));
      await tester.pumpAndSettle();

      expect(editStartedCalled, isTrue);
      expect(editEndedCalled, isFalse);

      // Close the edit dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(editEndedCalled, isTrue);
    });
  });
}
