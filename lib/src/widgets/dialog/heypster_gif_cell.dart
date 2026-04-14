import 'package:flutter/material.dart';

import '../../dto/heypster_media.dart';
import '../../dto/heypster_rendition.dart';
import '../../dto/misc.dart';
import '../heypster_media_view.dart';

/// A single GIF cell used in both the dialog picker and the grid.
///
/// Displays the GIF using [HeypsterMediaView] (video-first, with
/// GIF fallback) inside a tappable [InkWell] with rounded corners.
class HeypsterGifCell extends StatelessWidget {
  /// The media to display.
  final HeypsterMedia media;

  /// Called when the cell is tapped.
  final VoidCallback? onTap;

  /// Corner radius for the cell.
  final double cornerRadius;

  /// Which rendition to use.
  final HeypsterRendition renditionType;

  const HeypsterGifCell({
    super.key,
    required this.media,
    this.onTap,
    this.cornerRadius = 10,
    this.renditionType = HeypsterRendition.fixedWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: media.altText ?? media.title ?? 'GIF',
      button: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: InkWell(
            onTap: onTap,
            child: HeypsterMediaView(
              media: media,
              renditionType: renditionType,
              autoPlay: true,
              resizeMode: HeypsterResizeMode.cover,
            ),
          ),
        ),
      ),
    );
  }
}
