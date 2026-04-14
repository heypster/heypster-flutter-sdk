/// Content rating levels for filtering GIFs.
enum HeypsterRating {
  /// General audience.
  g,

  /// Parental guidance.
  pg,

  /// Parents strongly cautioned.
  pg13,

  /// Restricted.
  r,
}

/// Extension for converting [HeypsterRating] to and from string values.
extension HeypsterRatingExtension on HeypsterRating {
  /// Converts a string value to a [HeypsterRating].
  ///
  /// Returns `null` if the value is not recognized.
  static HeypsterRating? fromStringValue(String value) {
    switch (value) {
      case 'g':
        return HeypsterRating.g;
      case 'pg':
        return HeypsterRating.pg;
      case 'pg-13':
      case 'pg13':
        return HeypsterRating.pg13;
      case 'r':
        return HeypsterRating.r;
      default:
        return null;
    }
  }

  /// Converts a [HeypsterRating] to its API string representation.
  static String toStringValue(HeypsterRating rating) {
    switch (rating) {
      case HeypsterRating.g:
        return 'g';
      case HeypsterRating.pg:
        return 'pg';
      case HeypsterRating.pg13:
        return 'pg-13';
      case HeypsterRating.r:
        return 'r';
    }
  }
}
