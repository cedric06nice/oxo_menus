import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/widgets/template_card.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/widgets/template_status_indicator.dart';

const _draftTemplate = Menu(
  id: 1,
  name: 'Sunday Roast',
  status: Status.draft,
  version: '1.0.0',
  area: null,
);

final _publishedTemplate = Menu(
  id: 2,
  name: 'Evening Menu',
  status: Status.published,
  version: '2.1.0',
  area: null,
  dateUpdated: DateTime(2025, 6, 15, 10, 30),
);

Widget _buildCard({
  required Menu template,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  VoidCallback? onTap,
  TargetPlatform platform = TargetPlatform.android,
}) {
  return MaterialApp(
    theme: ThemeData(platform: platform),
    home: Scaffold(
      body: TemplateCard(
        template: template,
        onEdit: onEdit ?? () {},
        onDelete: onDelete ?? () {},
        onTap: onTap ?? () {},
      ),
    ),
  );
}

void main() {
  group('TemplateCard', () {
    testWidgets('displays template name', (tester) async {
      await tester.pumpWidget(_buildCard(template: _draftTemplate));

      expect(find.text('Sunday Roast'), findsOneWidget);
    });

    testWidgets('displays TemplateStatusIndicator', (tester) async {
      await tester.pumpWidget(_buildCard(template: _draftTemplate));

      expect(find.byType(TemplateStatusIndicator), findsOneWidget);
      expect(find.text('DRAFT'), findsOneWidget);
    });

    testWidgets('displays version', (tester) async {
      await tester.pumpWidget(_buildCard(template: _draftTemplate));

      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('displays date when dateUpdated is set', (tester) async {
      await tester.pumpWidget(_buildCard(template: _publishedTemplate));

      expect(find.textContaining('Updated:'), findsOneWidget);
    });

    testWidgets('does not display date when dateUpdated is null', (
      tester,
    ) async {
      await tester.pumpWidget(_buildCard(template: _draftTemplate));

      expect(find.textContaining('Updated:'), findsNothing);
    });

    testWidgets('has edit and delete icon buttons on Material', (tester) async {
      await tester.pumpWidget(_buildCard(template: _draftTemplate));

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('calls onEdit when edit button is tapped', (tester) async {
      var editCalled = false;
      await tester.pumpWidget(
        _buildCard(template: _draftTemplate, onEdit: () => editCalled = true),
      );

      await tester.tap(find.byIcon(Icons.edit));
      expect(editCalled, isTrue);
    });

    testWidgets('calls onDelete when delete button is tapped', (tester) async {
      var deleteCalled = false;
      await tester.pumpWidget(
        _buildCard(
          template: _draftTemplate,
          onDelete: () => deleteCalled = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      expect(deleteCalled, isTrue);
    });

    testWidgets('calls onTap when card body is tapped on Material', (
      tester,
    ) async {
      var tapCalled = false;
      await tester.pumpWidget(
        _buildCard(template: _draftTemplate, onTap: () => tapCalled = true),
      );

      // Tap the card body (the template name)
      await tester.tap(find.text('Sunday Roast'));
      expect(tapCalled, isTrue);
    });

    testWidgets('uses InkWell on Material platform', (tester) async {
      await tester.pumpWidget(_buildCard(template: _draftTemplate));

      // The top-level InkWell wrapping the card (not internal IconButton ones)
      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
      expect(inkWells.any((w) => w.child is Card), isTrue);
    });

    testWidgets('uses CupertinoButton on iOS platform', (tester) async {
      await tester.pumpWidget(
        _buildCard(template: _draftTemplate, platform: TargetPlatform.iOS),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is CupertinoButton && w.padding == EdgeInsets.zero,
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses CupertinoIcons on iOS platform', (tester) async {
      await tester.pumpWidget(
        _buildCard(template: _draftTemplate, platform: TargetPlatform.iOS),
      );

      expect(find.byIcon(CupertinoIcons.pencil), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.delete), findsOneWidget);
    });

    testWidgets('displays status for published template', (tester) async {
      await tester.pumpWidget(_buildCard(template: _publishedTemplate));

      expect(find.text('PUBLISHED'), findsOneWidget);
    });
  });
}
