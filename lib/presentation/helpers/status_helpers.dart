import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/status.dart';

/// Returns the foreground color for a status using theme colors.
Color statusColor(Status status, ColorScheme colorScheme) {
  return switch (status) {
    Status.draft => colorScheme.tertiary,
    Status.published => colorScheme.primary,
    Status.archived => colorScheme.outline,
  };
}

/// Returns the container/background color for a status using theme colors.
Color statusContainerColor(Status status, ColorScheme colorScheme) {
  return switch (status) {
    Status.draft => colorScheme.tertiaryContainer,
    Status.published => colorScheme.primaryContainer,
    Status.archived => colorScheme.outlineVariant,
  };
}
