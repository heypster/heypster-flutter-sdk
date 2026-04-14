import 'package:meta/meta.dart';

import 'heypster_image.dart';
import 'heypster_rendition.dart';

/// Container for all available renditions of a GIF.
///
/// Not all renditions are guaranteed to be present — check for null
/// before using a specific rendition.
@immutable
class HeypsterImages {
  /// Height set to 200px. Good for mobile use.
  final HeypsterImage? fixedHeight;

  /// Static preview image for fixed_height.
  final HeypsterImage? fixedHeightStill;

  /// Height set to 200px. Reduced to 6 frames.
  final HeypsterImage? fixedHeightDownsampled;

  /// Width set to 200px. Good for mobile use.
  final HeypsterImage? fixedWidth;

  /// Static preview image for fixed_width.
  final HeypsterImage? fixedWidthStill;

  /// Width set to 200px. Reduced to 6 frames.
  final HeypsterImage? fixedWidthDownsampled;

  /// Height set to 100px. Good for mobile keyboards.
  final HeypsterImage? fixedHeightSmall;

  /// Static preview image for fixed_height_small.
  final HeypsterImage? fixedHeightSmallStill;

  /// Width set to 100px. Good for mobile keyboards.
  final HeypsterImage? fixedWidthSmall;

  /// Static preview image for fixed_width_small.
  final HeypsterImage? fixedWidthSmallStill;

  /// File size under 2mb.
  final HeypsterImage? downsized;

  /// Static preview image for downsized.
  final HeypsterImage? downsizedStill;

  /// File size under 8mb.
  final HeypsterImage? downsizedLarge;

  /// File size under 5mb.
  final HeypsterImage? downsizedMedium;

  /// Original file size and dimensions.
  final HeypsterImage? original;

  /// Static preview image for original.
  final HeypsterImage? originalStill;

  /// Duration set to loop for 15 seconds.
  final HeypsterImage? looping;

  /// File size under 50kb. Good for thumbnails.
  final HeypsterImage? preview;

  /// File size under 200kb.
  final HeypsterImage? downsizedSmall;

  /// The media ID associated with these images.
  final String? mediaId;

  /// Creates a [HeypsterImages] instance.
  const HeypsterImages({
    this.fixedHeight,
    this.fixedHeightStill,
    this.fixedHeightDownsampled,
    this.fixedWidth,
    this.fixedWidthStill,
    this.fixedWidthDownsampled,
    this.fixedHeightSmall,
    this.fixedHeightSmallStill,
    this.fixedWidthSmall,
    this.fixedWidthSmallStill,
    this.downsized,
    this.downsizedStill,
    this.downsizedLarge,
    this.downsizedMedium,
    this.original,
    this.originalStill,
    this.looping,
    this.preview,
    this.downsizedSmall,
    this.mediaId,
  });

  /// Returns the [HeypsterImage] for the given [rendition], or null.
  HeypsterImage? imageFor(HeypsterRendition rendition) {
    switch (rendition) {
      case HeypsterRendition.original:
        return original;
      case HeypsterRendition.originalStill:
        return originalStill;
      case HeypsterRendition.preview:
        return preview;
      case HeypsterRendition.looping:
        return looping;
      case HeypsterRendition.fixedHeight:
        return fixedHeight;
      case HeypsterRendition.fixedHeightStill:
        return fixedHeightStill;
      case HeypsterRendition.fixedHeightDownsampled:
        return fixedHeightDownsampled;
      case HeypsterRendition.fixedHeightSmall:
        return fixedHeightSmall;
      case HeypsterRendition.fixedHeightSmallStill:
        return fixedHeightSmallStill;
      case HeypsterRendition.fixedWidth:
        return fixedWidth;
      case HeypsterRendition.fixedWidthStill:
        return fixedWidthStill;
      case HeypsterRendition.fixedWidthDownsampled:
        return fixedWidthDownsampled;
      case HeypsterRendition.fixedWidthSmall:
        return fixedWidthSmall;
      case HeypsterRendition.fixedWidthSmallStill:
        return fixedWidthSmallStill;
      case HeypsterRendition.downsized:
        return downsized;
      case HeypsterRendition.downsizedSmall:
        return downsizedSmall;
      case HeypsterRendition.downsizedMedium:
        return downsizedMedium;
      case HeypsterRendition.downsizedLarge:
        return downsizedLarge;
      case HeypsterRendition.downsizedStill:
        return downsizedStill;
    }
  }

  /// Creates a [HeypsterImages] from an API JSON response.
  ///
  /// Rendition keys are snake_case (e.g. `fixed_height`,
  /// `fixed_width`).
  factory HeypsterImages.fromJson(Map<String, dynamic> json) {
    HeypsterImage? parse(HeypsterRendition r) {
      final key = HeypsterRenditionUtil.toJsonKey(r);
      final data = json[key];
      if (data is Map<String, dynamic>) {
        return HeypsterImage.fromJson(data);
      }
      return null;
    }

    return HeypsterImages(
      fixedHeight: parse(HeypsterRendition.fixedHeight),
      fixedHeightStill: parse(HeypsterRendition.fixedHeightStill),
      fixedHeightDownsampled: parse(HeypsterRendition.fixedHeightDownsampled),
      fixedWidth: parse(HeypsterRendition.fixedWidth),
      fixedWidthStill: parse(HeypsterRendition.fixedWidthStill),
      fixedWidthDownsampled: parse(HeypsterRendition.fixedWidthDownsampled),
      fixedHeightSmall: parse(HeypsterRendition.fixedHeightSmall),
      fixedHeightSmallStill: parse(HeypsterRendition.fixedHeightSmallStill),
      fixedWidthSmall: parse(HeypsterRendition.fixedWidthSmall),
      fixedWidthSmallStill: parse(HeypsterRendition.fixedWidthSmallStill),
      downsized: parse(HeypsterRendition.downsized),
      downsizedStill: parse(HeypsterRendition.downsizedStill),
      downsizedLarge: parse(HeypsterRendition.downsizedLarge),
      downsizedMedium: parse(HeypsterRendition.downsizedMedium),
      original: parse(HeypsterRendition.original),
      originalStill: parse(HeypsterRendition.originalStill),
      looping: parse(HeypsterRendition.looping),
      preview: parse(HeypsterRendition.preview),
      downsizedSmall: parse(HeypsterRendition.downsizedSmall),
      mediaId: json['media_id'] as String?,
    );
  }

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    void put(HeypsterRendition r, HeypsterImage? img) {
      if (img != null) {
        map[HeypsterRenditionUtil.toJsonKey(r)] = img.toJson();
      }
    }

    put(HeypsterRendition.fixedHeight, fixedHeight);
    put(HeypsterRendition.fixedHeightStill, fixedHeightStill);
    put(HeypsterRendition.fixedHeightDownsampled, fixedHeightDownsampled);
    put(HeypsterRendition.fixedWidth, fixedWidth);
    put(HeypsterRendition.fixedWidthStill, fixedWidthStill);
    put(HeypsterRendition.fixedWidthDownsampled, fixedWidthDownsampled);
    put(HeypsterRendition.fixedHeightSmall, fixedHeightSmall);
    put(HeypsterRendition.fixedHeightSmallStill, fixedHeightSmallStill);
    put(HeypsterRendition.fixedWidthSmall, fixedWidthSmall);
    put(HeypsterRendition.fixedWidthSmallStill, fixedWidthSmallStill);
    put(HeypsterRendition.downsized, downsized);
    put(HeypsterRendition.downsizedStill, downsizedStill);
    put(HeypsterRendition.downsizedLarge, downsizedLarge);
    put(HeypsterRendition.downsizedMedium, downsizedMedium);
    put(HeypsterRendition.original, original);
    put(HeypsterRendition.originalStill, originalStill);
    put(HeypsterRendition.looping, looping);
    put(HeypsterRendition.preview, preview);
    put(HeypsterRendition.downsizedSmall, downsizedSmall);
    if (mediaId != null) map['media_id'] = mediaId;
    return map;
  }
}
