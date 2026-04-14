import 'package:meta/meta.dart';

import 'heypster_cache_policy.dart';
import 'heypster_content_type.dart';
import 'heypster_gif_quality.dart';
import 'heypster_language.dart';
import 'heypster_rating.dart';
import 'heypster_rendition.dart';
import 'heypster_theme.dart';
import 'misc.dart';

/// Configuration for the heypster dialog and grid view.
@immutable
class HeypsterSettings {
  /// Visual theme for the picker UI.
  final HeypsterTheme theme;

  /// Content types to show in the picker.
  final List<HeypsterContentType> mediaTypeConfig;

  /// Whether to show a confirmation screen before selection.
  final bool showConfirmationScreen;

  /// Content rating filter.
  final HeypsterRating rating;

  /// Rendition type for displaying GIFs in the grid.
  final HeypsterRendition? renditionType;

  /// Rendition type for the confirmation screen.
  final HeypsterRendition? confirmationRenditionType;

  /// The initially selected content type tab.
  final HeypsterContentType selectedContentType;

  /// Preferred file format.
  final HeypsterFileFormat fileFormat;

  /// Whether to show the emotion browsing button.
  final bool showEmotions;

  /// Language for tag search.
  final HeypsterLanguage? language;

  /// Cache policy for the SDK.
  final HeypsterCachePolicy? cachePolicy;

  /// GIF quality preference.
  final HeypsterGifQuality? gifQuality;

  /// Initial height of the picker sheet as a fraction of screen
  /// height (0.0 to 1.0). Defaults to 0.5 (half screen).
  final double initialSheetSize;

  /// Maximum height the picker sheet can expand to as a fraction
  /// of screen height (0.0 to 1.0). Defaults to 0.95.
  final double maxSheetSize;

  /// Minimum height the picker sheet can shrink to before
  /// dismissing, as a fraction of screen height. Defaults to 0.3.
  final double minSheetSize;

  /// Creates a [HeypsterSettings] instance.
  const HeypsterSettings({
    this.theme = HeypsterTheme.automaticTheme,
    this.mediaTypeConfig = const [
      HeypsterContentType.gif,
      HeypsterContentType.emoji,
    ],
    this.showConfirmationScreen = false,
    this.rating = HeypsterRating.pg13,
    this.renditionType,
    this.confirmationRenditionType,
    this.selectedContentType = HeypsterContentType.gif,
    this.fileFormat = HeypsterFileFormat.mp4,
    this.showEmotions = true,
    this.language,
    this.cachePolicy,
    this.gifQuality,
    this.initialSheetSize = 0.5,
    this.maxSheetSize = 0.95,
    this.minSheetSize = 0.3,
  });

  /// Creates a copy with the given fields replaced.
  HeypsterSettings copyWith({
    HeypsterTheme? theme,
    List<HeypsterContentType>? mediaTypeConfig,
    bool? showConfirmationScreen,
    HeypsterRating? rating,
    HeypsterRendition? renditionType,
    HeypsterRendition? confirmationRenditionType,
    HeypsterContentType? selectedContentType,
    HeypsterFileFormat? fileFormat,
    bool? showEmotions,
    HeypsterLanguage? language,
    HeypsterCachePolicy? cachePolicy,
    HeypsterGifQuality? gifQuality,
    double? initialSheetSize,
    double? maxSheetSize,
    double? minSheetSize,
  }) {
    return HeypsterSettings(
      theme: theme ?? this.theme,
      mediaTypeConfig: mediaTypeConfig ?? this.mediaTypeConfig,
      showConfirmationScreen:
          showConfirmationScreen ?? this.showConfirmationScreen,
      rating: rating ?? this.rating,
      renditionType: renditionType ?? this.renditionType,
      confirmationRenditionType:
          confirmationRenditionType ?? this.confirmationRenditionType,
      selectedContentType: selectedContentType ?? this.selectedContentType,
      fileFormat: fileFormat ?? this.fileFormat,
      showEmotions: showEmotions ?? this.showEmotions,
      language: language ?? this.language,
      cachePolicy: cachePolicy ?? this.cachePolicy,
      gifQuality: gifQuality ?? this.gifQuality,
      initialSheetSize: initialSheetSize ?? this.initialSheetSize,
      maxSheetSize: maxSheetSize ?? this.maxSheetSize,
      minSheetSize: minSheetSize ?? this.minSheetSize,
    );
  }

  /// Whether the given content type is enabled.
  bool isContentTypeEnabled(HeypsterContentType contentType) =>
      mediaTypeConfig.contains(contentType);
}
