import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/view_model.dart';

/// Pumps a screen with a directly-injected [ViewModel] — no `ProviderScope`.
///
/// Use in widget tests for migrated features. Constructs a hand-rolled VM
/// (typically with fake gateways) and renders the screen inside a minimal
/// `MaterialApp`. The harness disposes the ViewModel automatically when the
/// test ends.
///
/// Example:
/// ```dart
/// final vm = SettingsViewModel(
///   loadSettings: FakeLoadSettingsUseCase(...),
///   updateTheme: FakeUpdateThemeUseCase(...),
/// );
/// await pumpScreenWithViewModel(
///   tester,
///   viewModel: vm,
///   screenBuilder: (vm) => SettingsScreen(viewModel: vm),
/// );
/// ```
Future<void> pumpScreenWithViewModel<V extends ViewModel<Object?>>(
  WidgetTester tester, {
  required V viewModel,
  required Widget Function(V viewModel) screenBuilder,
  ThemeData? theme,
}) async {
  addTearDown(() {
    if (!viewModel.isDisposed) {
      viewModel.dispose();
    }
  });

  await tester.pumpWidget(
    MaterialApp(theme: theme, home: screenBuilder(viewModel)),
  );
}
