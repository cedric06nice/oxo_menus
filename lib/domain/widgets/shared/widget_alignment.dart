import 'package:flutter/widgets.dart';

/// Template-level alignment for widget rendering.
///
/// `justified` lays out a price line with name on the left and price on the
/// right, with decimals aligned on the integer/dot column.
enum WidgetAlignment { start, center, end, justified }

extension WidgetAlignmentRender on WidgetAlignment {
  CrossAxisAlignment get crossAxis => switch (this) {
    WidgetAlignment.start => CrossAxisAlignment.start,
    WidgetAlignment.center => CrossAxisAlignment.center,
    WidgetAlignment.end => CrossAxisAlignment.end,
    WidgetAlignment.justified => CrossAxisAlignment.stretch,
  };

  TextAlign get textAlign => switch (this) {
    WidgetAlignment.start || WidgetAlignment.justified => TextAlign.start,
    WidgetAlignment.center => TextAlign.center,
    WidgetAlignment.end => TextAlign.end,
  };

  bool get isJustified => this == WidgetAlignment.justified;
}
