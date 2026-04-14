/// Types of content available in the heypster picker.
enum HeypsterContentType {
  /// Animated GIFs.
  gif,

  /// Emoji GIFs.
  emoji,
}

/// Extension for converting [HeypsterContentType] to and from strings.
extension HeypsterContentTypeExtension on HeypsterContentType {
  /// Converts a string value to a [HeypsterContentType].
  ///
  /// Returns `null` if the value is not recognized.
  static HeypsterContentType? fromStringValue(String value) {
    switch (value) {
      case 'gif':
        return HeypsterContentType.gif;
      case 'emoji':
        return HeypsterContentType.emoji;
      default:
        return null;
    }
  }

  /// Converts a [HeypsterContentType] to its string representation.
  static String toStringValue(HeypsterContentType type) => type.name;
}
