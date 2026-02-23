import 'package:flutter/material.dart';
import 'package:oxo_menus/domain/entities/status.dart';
import 'package:oxo_menus/presentation/widgets/common/status_badge.dart';

/// Displays a status badge pill for templates.
///
/// Delegates to [StatusBadge] for unified styling.
class TemplateStatusIndicator extends StatelessWidget {
  final Status status;

  const TemplateStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StatusBadge(status: status);
  }
}
