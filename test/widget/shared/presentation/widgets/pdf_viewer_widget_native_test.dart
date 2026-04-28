import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/presentation/widgets/pdf_viewer_widget.dart';
import 'package:printing/printing.dart';

void main() {
  final testBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]); // %PDF

  group('PdfViewerWidget (native)', () {
    testWidgets('renders PdfPreview with provided bytes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PdfViewerWidget(pdfBytes: testBytes, filename: 'test.pdf'),
          ),
        ),
      );

      expect(find.byType(PdfPreview), findsOneWidget);
    });

    testWidgets('includes share action with Material icon on Android', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: PdfViewerWidget(pdfBytes: testBytes, filename: 'test.pdf'),
          ),
        ),
      );

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('wraps content in InteractiveViewer for pinch-to-zoom', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PdfViewerWidget(pdfBytes: testBytes, filename: 'test.pdf'),
          ),
        ),
      );

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('includes share action with Cupertino icon on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: PdfViewerWidget(pdfBytes: testBytes, filename: 'test.pdf'),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.share_up), findsOneWidget);
    });
  });
}
