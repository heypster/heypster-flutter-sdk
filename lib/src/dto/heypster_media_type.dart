/// Types of media available on heypster.
enum HeypsterMediaType {
  /// An animated GIF.
  gif,

  /// An emoji GIF.
  emoji,
}

/// Extension for converting [HeypsterMediaType] to and from strings.
extension HeypsterMediaTypeExtension on HeypsterMediaType {
  /// Converts a string value to a [HeypsterMediaType].
  ///
  /// Returns `null` if the value is not recognized.
  static HeypsterMediaType? fromStringValue(String value) {
    switch (value) {
      case 'gif':
        return HeypsterMediaType.gif;
      case 'emoji':
        return HeypsterMediaType.emoji;
      default:
        return null;
    }
  }

  /// Converts a [HeypsterMediaType] to its string representation.
  static String toStringValue(HeypsterMediaType type) => type.name;
}
