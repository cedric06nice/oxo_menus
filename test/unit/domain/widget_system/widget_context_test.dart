import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/domain/widgets/shared/widget_alignment.dart';

void main() {
  // -------------------------------------------------------------------------
  // WidgetContext
  // -------------------------------------------------------------------------

  group('WidgetContext', () {
    group('construction defaults', () {
      test(
        'should expose isEditable when constructed with isEditable true',
        () {
          const context = WidgetContext(isEditable: true);

          expect(context.isEditable, isTrue);
        },
      );

      test('should expose isEditable as false when constructed with false', () {
        const context = WidgetContext(isEditable: false);

        expect(context.isEditable, isFalse);
      });

      test('should default onUpdate to null when not provided', () {
        const context = WidgetContext(isEditable: true);

        expect(context.onUpdate, isNull);
      });

      test('should default onDelete to null when not provided', () {
        const context = WidgetContext(isEditable: true);

        expect(context.onDelete, isNull);
      });

      test('should default onEditStarted to null when not provided', () {
        const context = WidgetContext(isEditable: true);

        expect(context.onEditStarted, isNull);
      });

      test('should default onEditEnded to null when not provided', () {
        const context = WidgetContext(isEditable: true);

        expect(context.onEditEnded, isNull);
      });

      test('should default displayOptions to null when not provided', () {
        const context = WidgetContext(isEditable: true);

        expect(context.displayOptions, isNull);
      });

      test(
        'should default alignment to WidgetAlignment.start when not provided',
        () {
          const context = WidgetContext(isEditable: true);

          expect(context.alignment, equals(WidgetAlignment.start));
        },
      );
    });

    group('onUpdate callback', () {
      test('should store onUpdate callback when provided', () {
        final context = WidgetContext(isEditable: true, onUpdate: (_) {});

        expect(context.onUpdate, isNotNull);
      });

      test('should invoke onUpdate with the exact map passed', () {
        Map<String, dynamic>? captured;
        final context = WidgetContext(
          isEditable: true,
          onUpdate: (props) => captured = props,
        );
        final update = <String, dynamic>{'name': 'Soup', 'price': 5.5};

        context.onUpdate!(update);

        expect(captured, same(update));
      });

      test('should invoke onUpdate multiple times independently', () {
        final calls = <Map<String, dynamic>>[];
        final context = WidgetContext(
          isEditable: true,
          onUpdate: (props) => calls.add(props),
        );

        context.onUpdate!({'name': 'first'});
        context.onUpdate!({'name': 'second'});

        expect(calls, hasLength(2));
        expect(calls[0]['name'], equals('first'));
        expect(calls[1]['name'], equals('second'));
      });
    });

    group('onDelete callback', () {
      test('should store onDelete callback when provided', () {
        final context = WidgetContext(isEditable: true, onDelete: () {});

        expect(context.onDelete, isNotNull);
      });

      test('should invoke onDelete when called', () {
        var called = false;
        final context = WidgetContext(
          isEditable: true,
          onDelete: () => called = true,
        );

        context.onDelete!();

        expect(called, isTrue);
      });
    });

    group('onEditStarted callback', () {
      test('should store onEditStarted callback when provided', () {
        final context = WidgetContext(isEditable: true, onEditStarted: () {});

        expect(context.onEditStarted, isNotNull);
      });

      test('should invoke onEditStarted when called', () {
        var called = false;
        final context = WidgetContext(
          isEditable: true,
          onEditStarted: () => called = true,
        );

        context.onEditStarted!();

        expect(called, isTrue);
      });
    });

    group('onEditEnded callback', () {
      test('should store onEditEnded callback when provided', () {
        final context = WidgetContext(isEditable: true, onEditEnded: () {});

        expect(context.onEditEnded, isNotNull);
      });

      test('should invoke onEditEnded when called', () {
        var called = false;
        final context = WidgetContext(
          isEditable: true,
          onEditEnded: () => called = true,
        );

        context.onEditEnded!();

        expect(called, isTrue);
      });
    });

    group('displayOptions', () {
      test('should expose displayOptions when provided', () {
        const options = MenuDisplayOptions(
          showPrices: false,
          showAllergens: true,
        );
        final context = WidgetContext(
          isEditable: true,
          displayOptions: options,
        );

        expect(context.displayOptions, equals(options));
      });

      test('should expose showPrices from displayOptions', () {
        const options = MenuDisplayOptions(
          showPrices: false,
          showAllergens: true,
        );
        final context = WidgetContext(
          isEditable: false,
          displayOptions: options,
        );

        expect(context.displayOptions!.showPrices, isFalse);
      });

      test('should expose showAllergens from displayOptions', () {
        const options = MenuDisplayOptions(
          showPrices: true,
          showAllergens: false,
        );
        final context = WidgetContext(
          isEditable: false,
          displayOptions: options,
        );

        expect(context.displayOptions!.showAllergens, isFalse);
      });
    });

    group('alignment', () {
      test('should expose start alignment when set to start', () {
        const context = WidgetContext(
          isEditable: false,
          alignment: WidgetAlignment.start,
        );

        expect(context.alignment, equals(WidgetAlignment.start));
      });

      test('should expose center alignment when set to center', () {
        const context = WidgetContext(
          isEditable: false,
          alignment: WidgetAlignment.center,
        );

        expect(context.alignment, equals(WidgetAlignment.center));
      });

      test('should expose end alignment when set to end', () {
        const context = WidgetContext(
          isEditable: false,
          alignment: WidgetAlignment.end,
        );

        expect(context.alignment, equals(WidgetAlignment.end));
      });

      test('should expose justified alignment when set to justified', () {
        const context = WidgetContext(
          isEditable: false,
          alignment: WidgetAlignment.justified,
        );

        expect(context.alignment, equals(WidgetAlignment.justified));
      });
    });
  });
}
