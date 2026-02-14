import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxo_menus/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/domain/widget_system/widget_definition.dart';
import 'package:oxo_menus/presentation/providers/repositories_provider.dart';

/// Widget that displays an image from Directus
class ImageWidget extends ConsumerWidget {
  final ImageProps props;
  final WidgetContext context;

  const ImageWidget({super.key, required this.props, required this.context});

  @override
  Widget build(BuildContext buildContext, WidgetRef ref) {
    final baseUrl = ref.watch(directusBaseUrlProvider);
    final imageUrl = '$baseUrl/assets/${props.fileId}';

    return Align(
      alignment: _getAlignment(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(8.0),
        child: Image.network(
          imageUrl,
          width: props.width,
          height: props.height,
          fit: _getBoxFit(),
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: props.width ?? 100,
              height: props.height ?? 100,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
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
