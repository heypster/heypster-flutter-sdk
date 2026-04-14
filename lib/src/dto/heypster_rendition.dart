/// An enumeration representing a Heypster rendition type.
///
/// Renditions are different versions of a GIF optimized for various
/// use cases (e.g., thumbnails, mobile, desktop).
enum HeypsterRendition {
  /// Original file size and file dimensions.
  original,

  /// Static preview image for original.
  originalStill,

  /// File size under 50kb. Good for thumbnails and previews.
  preview,

  /// Duration set to loop for 15 seconds.
  looping,

  /// Height set to 200px. Good for mobile use.
  fixedHeight,

  /// Static preview image for fixed_height.
  fixedHeightStill,

  /// Height set to 200px. Reduced to 6 frames.
  fixedHeightDownsampled,

  /// Height set to 100px. Good for mobile keyboards.
  fixedHeightSmall,

  /// Static preview image for fixed_height_small.
  fixedHeightSmallStill,

  /// Width set to 200px. Good for mobile use.
  fixedWidth,

  /// Static preview image for fixed_width.
  fixedWidthStill,

  /// Width set to 200px. Reduced to 6 frames.
  fixedWidthDownsampled,

  /// Width set to 100px. Good for mobile keyboards.
  fixedWidthSmall,

  /// Static preview image for fixed_width_small.
  fixedWidthSmallStill,

  /// File size under 2mb.
  downsized,

  /// File size under 200kb.
  downsizedSmall,

  /// File size under 5mb.
  downsizedMedium,

  /// File size under 8mb.
  downsizedLarge,

  /// Static preview image for downsized.
  downsizedStill,
}

/// Utility for converting between [HeypsterRendition] and string values.
class HeypsterRenditionUtil {
  HeypsterRenditionUtil._();

  static const _toJsonKeyMap = {
    HeypsterRendition.original: 'original',
    HeypsterRendition.originalStill: 'original_still',
    HeypsterRendition.preview: 'preview',
    HeypsterRendition.looping: 'looping',
    HeypsterRendition.fixedHeight: 'fixed_height',
    HeypsterRendition.fixedHeightStill: 'fixed_height_still',
    HeypsterRendition.fixedHeightDownsampled: 'fixed_height_downsampled',
    HeypsterRendition.fixedHeightSmall: 'fixed_height_small',
    HeypsterRendition.fixedHeightSmallStill: 'fixed_height_small_still',
    HeypsterRendition.fixedWidth: 'fixed_width',
    HeypsterRendition.fixedWidthStill: 'fixed_width_still',
    HeypsterRendition.fixedWidthDownsampled: 'fixed_width_downsampled',
    HeypsterRendition.fixedWidthSmall: 'fixed_width_small',
    HeypsterRendition.fixedWidthSmallStill: 'fixed_width_small_still',
    HeypsterRendition.downsized: 'downsized',
    HeypsterRendition.downsizedSmall: 'downsized_small',
    HeypsterRendition.downsizedMedium: 'downsized_medium',
    HeypsterRendition.downsizedLarge: 'downsized_large',
    HeypsterRendition.downsizedStill: 'downsized_still',
  };

  static final _fromJsonKeyMap = {
    for (final entry in _toJsonKeyMap.entries) entry.value: entry.key,
  };

  /// Converts a [HeypsterRendition] to the JSON key used in API
  /// responses (snake_case).
  static String toJsonKey(HeypsterRendition rendition) =>
      _toJsonKeyMap[rendition] ?? rendition.name;

  /// Converts a snake_case JSON key to a [HeypsterRendition].
  ///
  /// Returns `null` if the key is not recognized.
  static HeypsterRendition? fromJsonKey(String key) => _fromJsonKeyMap[key];

  /// Converts a [HeypsterRendition] to its camelCase string name.
  static String toStringValue(HeypsterRendition rendition) => rendition.name;

  /// Converts a camelCase string name to a [HeypsterRendition].
  ///
  /// Returns `null` if the name is not recognized.
  static HeypsterRendition? fromStringValue(String value) {
    for (final r in HeypsterRendition.values) {
      if (r.name == value) return r;
    }
    return null;
  }
}
