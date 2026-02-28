import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/entities/area.dart';
import 'package:oxo_menus/domain/entities/size.dart' as domain;
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/domain/repositories/area_repository.dart';
import 'package:oxo_menus/domain/repositories/size_repository.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/pages/menu_list/widgets/template_create_dialog.dart';

class MockSizeRepository extends Mock implements SizeRepository {}

class MockAreaRepository extends Mock implements AreaRepository {}

void main() {
  late MockSizeRepository mockSizeRepository;
  late MockAreaRepository mockAreaRepository;

  final testSizes = [
    const domain.Size(
      id: 1,
      name: 'A4',
      width: 210,
      height: 297,
      direction: 'portrait',
      status: Status.published,
    ),
  ];

  setUp(() {
    mockSizeRepository = MockSizeRepository();
    mockAreaRepository = MockAreaRepository();
    when(
      () => mockSizeRepository.getAll(),
    ).thenAnswer((_) async => Success(testSizes));
    when(
      () => mockAreaRepository.getAll(),
    ).thenAnswer((_) async => const Success([Area(id: 1, name: 'Dining')]));
  });

  group('TemplateCreateDialog', () {
    testWidgets('renders AlertDialog on Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
            areaRepositoryProvider.overrideWithValue(mockAreaRepository),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => TemplateCreateDialog(onSave: (_) {}),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Create Template'), findsOneWidget);
    });

    testWidgets('renders CupertinoPageScaffold on iOS', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
            areaRepositoryProvider.overrideWithValue(mockAreaRepository),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      fullscreenDialog: true,
                      builder: (_) => TemplateCreateDialog(onSave: (_) {}),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.text('Create Template'), findsOneWidget);
      expect(find.byType(CupertinoTextFormFieldRow), findsNWidgets(2));
    });

    testWidgets('shows CupertinoActivityIndicator while loading on iOS', (
      WidgetTester tester,
    ) async {
      final completer = Completer<Result<List<domain.Size>, DomainError>>();
      when(
        () => mockSizeRepository.getAll(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sizeRepositoryProvider.overrideWithValue(mockSizeRepository),
            areaRepositoryProvider.overrideWithValue(mockAreaRepository),
          ],
          child: MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      fullscreenDialog: true,
                      builder: (_) => TemplateCreateDialog(onSave: (_) {}),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });
  });
}
