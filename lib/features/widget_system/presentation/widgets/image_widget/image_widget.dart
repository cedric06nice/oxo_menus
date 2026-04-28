import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oxo_menus/features/widget_system/domain/widget_definition.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/image/image_props.dart';
import 'package:oxo_menus/features/widget_system/presentation/widgets/image_widget/image_edit_dialog.dart';
import 'package:oxo_menus/shared/presentation/helpers/edit_dialog_helper.dart';
import 'package:oxo_menus/shared/presentation/utils/platform_detection.dart';
import 'package:oxo_menus/shared/presentation/widgets/adaptive_loading_indicator.dart';

/// Widget that displays an image from Directus.
///
/// Pulls bytes through `context.imageGateway` (LRU-cached). The first build
/// captures the future; subsequent rebuilds reuse it so we don't re-fetch on
/// every layout change. When `fileId` changes the future is rebuilt.
class ImageWidget extends StatefulWidget {
  final ImageProps props;
  final WidgetContext context;

  const ImageWidget({super.key, required this.props, required this.context});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  Future<Uint8List>? _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.context.imageGateway?.getBytes(widget.props.fileId);
  }

  @override
  void didUpdateWidget(covariant ImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.props.fileId != widget.props.fileId ||
        oldWidget.context.imageGateway != widget.context.imageGateway) {
      _bytes = widget.context.imageGateway?.getBytes(widget.props.fileId);
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return GestureDetector(
      onTap: widget.context.isEditable ? () => _handleEdit(buildContext) : null,
      child: _buildImage(buildContext),
    );
  }

  Widget _buildImage(BuildContext ctx) {
    final colorScheme = Theme.of(ctx).colorScheme;
    final isApple = isApplePlatform(ctx);
    final future = _bytes;
    if (future == null) {
      return _placeholder(ctx, colorScheme, isApple);
    }
    return FutureBuilder<Uint8List>(
      future: future,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingBox();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _placeholder(ctx, colorScheme, isApple);
        }
        return Image.memory(
          snapshot.data!,
          width: widget.props.width,
          height: widget.props.height,
          fit: _getBoxFit(),
          alignment: _getAlignment(),
        );
      },
    );
  }

  Widget _loadingBox() {
    return Align(
      alignment: _getAlignment(),
      child: SizedBox(
        width: widget.props.width ?? 100,
        height: widget.props.height ?? 100,
        child: const Center(child: AdaptiveLoadingIndicator()),
      ),
    );
  }

  Widget _placeholder(BuildContext ctx, ColorScheme colorScheme, bool isApple) {
    return Align(
      alignment: _getAlignment(),
      child: Container(
        width: widget.props.width ?? 100,
        height: widget.props.height ?? 100,
        color: colorScheme.surfaceContainerHigh,
        child: Icon(
          isApple ? CupertinoIcons.photo : Icons.broken_image,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _handleEdit(BuildContext buildContext) async {
    widget.context.onEditStarted?.call();
    await showEditDialog(
      buildContext,
      ImageEditDialog(
        props: widget.props,
        imageGateway: widget.context.imageGateway,
        onSave: (updatedProps) {
          widget.context.onUpdate?.call(updatedProps.toJson());
        },
      ),
    );
    widget.context.onEditEnded?.call();
  }

  Alignment _getAlignment() {
    switch (widget.props.align.toLowerCase()) {
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
    switch (widget.props.fit.toLowerCase()) {
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
