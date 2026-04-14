import 'package:meta/meta.dart';

import 'heypster_images.dart';
import 'heypster_media_type.dart';
import 'heypster_rating.dart';

/// A GIF or media item from the heypster API.
///
/// Mirrors the structure of Giphy's media object for familiar DX.
/// Fields specific to Giphy that heypster does not support (user
/// profiles, video clips, stickers, dynamic text) are omitted.
@immutable
class HeypsterMedia {
  /// The unique identifier for the media.
  final String id;

  /// The type of media.
  final HeypsterMediaType? type;

  /// The slug (URL-friendly identifier).
  final String? slug;

  /// The URL for the media on heypster.
  final String? url;

  /// The embed URL for the media.
  final String? embedUrl;

  /// The source URL of the media.
  final String? source;

  /// The title of the media.
  final String? title;

  /// The content rating.
  final HeypsterRating? rating;

  /// The content URL of the media.
  final String? contentUrl;

  /// Tags associated with the media.
  final List<String>? tags;

  /// The image renditions.
  final HeypsterImages images;

  /// The date the media was last updated.
  final DateTime? updateDate;

  /// The date the media was created.
  final DateTime? createDate;

  /// The date the media was imported.
  final DateTime? importDate;

  /// The date the media started trending.
  final DateTime? trendingDate;

  /// Whether the media is featured.
  final bool isFeatured;

  /// Alt text for accessibility.
  final String? altText;

  /// The aspect ratio of the media (width / height).
  final double aspectRatio;

  /// Creates a [HeypsterMedia] instance.
  const HeypsterMedia({
    required this.id,
    this.type,
    this.slug,
    this.url,
    this.embedUrl,
    this.source,
    this.title,
    this.rating,
    this.contentUrl,
    this.tags,
    required this.images,
    this.updateDate,
    this.createDate,
    this.importDate,
    this.trendingDate,
    this.isFeatured = false,
    this.altText,
    this.aspectRatio = 1.75,
  });

  /// Creates a [HeypsterMedia] from an API JSON response.
  ///
  /// Handles the GIPHY-compatible API format with snake_case keys.
  factory HeypsterMedia.fromJson(Map<String, dynamic> json) {
    return HeypsterMedia(
      id: json['id'] as String,
      type: json['type'] != null
          ? HeypsterMediaTypeExtension.fromStringValue(json['type'] as String)
          : null,
      slug: json['slug'] as String?,
      url: json['url'] as String?,
      embedUrl: json['embed_url'] as String?,
      source: json['source'] as String?,
      title: json['title'] as String?,
      rating: json['rating'] != null
          ? HeypsterRatingExtension.fromStringValue(json['rating'] as String)
          : null,
      contentUrl: json['content_url'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.whereType<String>().toList(),
      images: HeypsterImages.fromJson(
        json['images'] as Map<String, dynamic>? ?? {},
      ),
      updateDate: _parseDate(json['update_datetime']),
      createDate: _parseDate(json['create_datetime']),
      importDate: _parseDate(json['import_datetime']),
      trendingDate: _parseDate(json['trending_datetime']),
      isFeatured: json['is_featured'] as bool? ?? false,
      altText: json['alt_text'] as String?,
      aspectRatio: _parseAspectRatio(json),
    );
  }

  /// Converts this media to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type != null
        ? HeypsterMediaTypeExtension.toStringValue(type!)
        : null,
    'slug': slug,
    'url': url,
    'embed_url': embedUrl,
    'source': source,
    'title': title,
    'rating': rating != null
        ? HeypsterRatingExtension.toStringValue(rating!)
        : null,
    'content_url': contentUrl,
    'tags': tags,
    'images': images.toJson(),
    'update_datetime': updateDate?.toIso8601String(),
    'create_datetime': createDate?.toIso8601String(),
    'import_datetime': importDate?.toIso8601String(),
    'trending_datetime': trendingDate?.toIso8601String(),
    'is_featured': isFeatured,
    'alt_text': altText,
  };

  static DateTime? _parseDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      // The API returns "0000-00-00 00:00:00" for unset dates
      if (value.startsWith('0000')) return null;
      return DateTime.tryParse(value);
    }
    return null;
  }

  static double _parseAspectRatio(Map<String, dynamic> json) {
    // Try explicit aspect ratio first
    if (json['aspect_ratio'] is num) {
      return (json['aspect_ratio'] as num).toDouble();
    }
    // Compute from original image dimensions
    final images = json['images'];
    if (images is Map<String, dynamic>) {
      final original = images['original'];
      if (original is Map<String, dynamic>) {
        final w = _parseDimension(original['width']);
        final h = _parseDimension(original['height']);
        if (w > 0 && h > 0) return w / h;
      }
    }
    return 1.75;
  }

  static double _parseDimension(Object? value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
