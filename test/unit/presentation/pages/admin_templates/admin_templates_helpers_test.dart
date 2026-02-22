import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/pages/admin_templates/admin_templates_helpers.dart';

void main() {
  // Use a standard Material 3 light color scheme for deterministic testing
  final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

  group('statusColor', () {
    test('returns colorScheme.tertiary for Status.draft', () {
      expect(statusColor(Status.draft, colorScheme), colorScheme.tertiary);
    });

    test('returns colorScheme.primary for Status.published', () {
      expect(statusColor(Status.published, colorScheme), colorScheme.primary);
    });

    test('returns colorScheme.outline for Status.archived', () {
      expect(statusColor(Status.archived, colorScheme), colorScheme.outline);
    });
  });

  group('statusContainerColor', () {
    test('returns colorScheme.tertiaryContainer for Status.draft', () {
      expect(
        statusContainerColor(Status.draft, colorScheme),
        colorScheme.tertiaryContainer,
      );
    });

    test('returns colorScheme.primaryContainer for Status.published', () {
      expect(
        statusContainerColor(Status.published, colorScheme),
        colorScheme.primaryContainer,
      );
    });

    test('returns colorScheme.outlineVariant for Status.archived', () {
      expect(
        statusContainerColor(Status.archived, colorScheme),
        colorScheme.outlineVariant,
      );
    });
  });
}
