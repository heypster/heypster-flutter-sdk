import 'package:meta/meta.dart';

import 'heypster_badge.dart';
import 'heypster_emotion.dart';
import 'heypster_media_type.dart';
import 'heypster_rating.dart';
import 'heypster_tag.dart';

/// Types of content requests.
enum HeypsterContentRequestType {
  /// Trending / GIFs of the day.
  trending,

  /// Search by text query.
  search,

  /// Emoji GIFs.
  emoji,

  /// GIFs by tag (native API).
  byTag,

  /// GIFs by emotion (native API).
  byEmotion,

  /// GIFs by badge (native API).
  byBadge,

  /// GIFs of the day (native API).
  gifsOfTheDay,
}

/// Describes what content to load in a [HeypsterGridView].
///
/// Use the factory constructors for common request types.
@immutable
class HeypsterContentRequest {
  /// The media type for the content.
  final HeypsterMediaType mediaType;

  /// The content rating filter.
  final HeypsterRating? rating;

  /// The type of request.
  final HeypsterContentRequestType requestType;

  /// The search query, if applicable.
  final String? searchQuery;

  /// The tag to filter by, for [HeypsterContentRequestType.byTag].
  final HeypsterTag? tag;

  /// The emotion to filter by, for
  /// [HeypsterContentRequestType.byEmotion].
  final HeypsterEmotion? emotion;

  /// The badge to filter by, for
  /// [HeypsterContentRequestType.byBadge].
  final HeypsterBadge? badge;

  /// Creates a [HeypsterContentRequest].
  const HeypsterContentRequest({
    required this.mediaType,
    this.rating,
    required this.requestType,
    this.searchQuery,
    this.tag,
    this.emotion,
    this.badge,
  });

  /// Search for GIFs matching a text query.
  factory HeypsterContentRequest.search({
    required String searchQuery,
    HeypsterMediaType mediaType = HeypsterMediaType.gif,
    HeypsterRating rating = HeypsterRating.pg13,
  }) {
    return HeypsterContentRequest(
      requestType: HeypsterContentRequestType.search,
      mediaType: mediaType,
      rating: rating,
      searchQuery: searchQuery,
    );
  }

  /// Trending / featured GIFs.
  factory HeypsterContentRequest.trending({
    HeypsterMediaType mediaType = HeypsterMediaType.gif,
    HeypsterRating rating = HeypsterRating.pg13,
  }) {
    return HeypsterContentRequest(
      requestType: HeypsterContentRequestType.trending,
      mediaType: mediaType,
      rating: rating,
    );
  }

  /// Trending GIFs (convenience shorthand).
  factory HeypsterContentRequest.trendingGifs({
    HeypsterRating rating = HeypsterRating.pg13,
  }) {
    return HeypsterContentRequest.trending(
      mediaType: HeypsterMediaType.gif,
      rating: rating,
    );
  }

  /// Emoji GIFs.
  factory HeypsterContentRequest.emoji() {
    return const HeypsterContentRequest(
      requestType: HeypsterContentRequestType.emoji,
      mediaType: HeypsterMediaType.emoji,
    );
  }

  /// GIFs for a specific tag (uses native heypster API).
  factory HeypsterContentRequest.byTag(HeypsterTag tag) {
    return HeypsterContentRequest(
      requestType: HeypsterContentRequestType.byTag,
      mediaType: HeypsterMediaType.gif,
      tag: tag,
    );
  }

  /// GIFs for a specific emotion (uses native heypster API).
  factory HeypsterContentRequest.byEmotion(HeypsterEmotion emotion) {
    return HeypsterContentRequest(
      requestType: HeypsterContentRequestType.byEmotion,
      mediaType: HeypsterMediaType.gif,
      emotion: emotion,
    );
  }

  /// GIFs for a specific badge (uses native heypster API).
  factory HeypsterContentRequest.byBadge(HeypsterBadge badge) {
    return HeypsterContentRequest(
      requestType: HeypsterContentRequestType.byBadge,
      mediaType: HeypsterMediaType.gif,
      badge: badge,
    );
  }

  /// GIFs of the day (uses native heypster API).
  factory HeypsterContentRequest.gifsOfTheDay() {
    return const HeypsterContentRequest(
      requestType: HeypsterContentRequestType.gifsOfTheDay,
      mediaType: HeypsterMediaType.gif,
    );
  }
}
