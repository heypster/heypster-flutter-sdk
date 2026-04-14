/// Scroll direction for grid views.
enum HeypsterDirection {
  /// Horizontal scrolling.
  horizontal,

  /// Vertical scrolling.
  vertical,
}

/// How media content is resized to fit its container.
enum HeypsterResizeMode {
  /// Center the content without scaling.
  center,

  /// Scale to fit within bounds, preserving aspect ratio.
  contain,

  /// Scale to fill bounds, preserving aspect ratio (may crop).
  cover,

  /// Stretch to fill bounds exactly (may distort).
  stretch,
}

/// Preset themes for the heypster UI.
enum HeypsterThemePreset {
  /// Adapts to the system brightness (light/dark).
  automatic,

  /// Dark theme.
  dark,

  /// Light theme.
  light,
}

/// File format preference for GIF content.
enum HeypsterFileFormat {
  /// GIF format.
  gif,

  /// MP4 video format.
  mp4,

  /// WebP format.
  webp,
}
