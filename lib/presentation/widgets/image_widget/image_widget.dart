import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/helpers/edit_dialog_helper.dart';
import 'package:oxo_menus/presentation/utils/platform_detection.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';
import 'package:oxo_menus/presentation/widgets/common/adaptive_loading_indicator.dart';
import 'package:oxo_menus/presentation/widgets/image_widget/image_edit_dialog.dart';

/// Widget that displays an image from Directus
class ImageWidget extends ConsumerWidget {
  final ImageProps props;
  final WidgetContext context;

  const ImageWidget({super.key, required this.props, required this.context});

  @override
  Widget build(BuildContext buildContext, WidgetRef ref) {
    final asyncBytes = ref.watch(imageDataProvider(props.fileId));

    return GestureDetector(
      onTap: context.isEditable ? () => _handleEdit(buildContext) : null,
      child: Align(
        alignment: _getAlignment(),
        child: SizedBox(
          width: double.infinity,
          child: Builder(
            builder: (ctx) {
              final colorScheme = Theme.of(ctx).colorScheme;
              final isApple = isApplePlatform(ctx);
              return asyncBytes.when(
                data: (bytes) => Image.memory(
                  bytes,
                  width: props.width,
                  height: props.height,
                  fit: _getBoxFit(),
                ),
                loading: () => SizedBox(
                  width: props.width ?? 100,
                  height: props.height ?? 100,
                  child: Center(child: const AdaptiveLoadingIndicator()),
                ),
                error: (_, _) => Container(
                  width: props.width ?? 100,
                  height: props.height ?? 100,
                  color: colorScheme.surfaceContainerHigh,
                  child: Icon(
                    isApple ? CupertinoIcons.photo : Icons.broken_image,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleEdit(BuildContext buildContext) async {
    context.onEditStarted?.call();
    await showEditDialog(
      buildContext,
      ImageEditDialog(
        props: props,
        onSave: (updatedProps) {
          context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
    context.onEditEnded?.call();
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
