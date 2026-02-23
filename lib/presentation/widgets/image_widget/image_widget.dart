import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/image_widget/image_edit_dialog.dart';

/// Widget that displays an image from Directus
class ImageWidget extends ConsumerWidget {
  final ImageProps props;
  final WidgetContext context;

  const ImageWidget({super.key, required this.props, required this.context});

  @override
  Widget build(BuildContext buildContext, WidgetRef ref) {
    final baseUrl = ref.watch(directusBaseUrlProvider);
    final imageUrl = '$baseUrl/assets/${props.fileId}';

    return GestureDetector(
      onTap: context.isEditable ? () => _handleEdit(buildContext) : null,
      child: Align(
        alignment: _getAlignment(),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: const EdgeInsets.all(8.0),
          child: Builder(
            builder: (ctx) {
              final colorScheme = Theme.of(ctx).colorScheme;
              return Image.network(
                imageUrl,
                width: props.width,
                height: props.height,
                fit: _getBoxFit(),
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: props.width ?? 100,
                    height: props.height ?? 100,
                    color: colorScheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.broken_image,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleEdit(BuildContext buildContext) {
    showDialog<ImageProps>(
      context: buildContext,
      builder: (dialogContext) => ImageEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
  }

  Alignment _getAlignment() {
    switch (props.align.toLowerCase()) {
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      case 'center':
      default:
        return Alignment.center;
    }
  }

  BoxFit _getBoxFit() {
    switch (props.fit.toLowerCase()) {
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'fitwidth':
        return BoxFit.fitWidth;
      case 'fitheight':
        return BoxFit.fitHeight;
      case 'contain':
      default:
        return BoxFit.contain;
    }
  }
}
