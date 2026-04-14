import 'package:meta/meta.dart';

import 'heypster_badge.dart';
import 'heypster_emotion.dart';
import 'heypster_image.dart';
import 'heypster_images.dart';
import 'heypster_media.dart';
import 'heypster_tag.dart';

/// A GIF as returned by the native heypster SDK API.
///
/// This is distinct from [HeypsterMedia] which mirrors the
/// GIPHY-compatible response format. Use [toHeypsterMedia] to
/// convert to the Giphy-shaped model when needed.
@immutable
class HeypsterNativeGif {
  /// Content base URL for building full URLs.
  static const _contentBaseUrl = 'https://heypster-gif.com/';

  /// The unique identifier.
  final int id;

  /// Relative path to the H265 MP4 video, if available.
  final String? h265;

  /// Relative path to the H264 MP4 video, if available.
  final String? h264;

  /// Relative path to the mini (240p) GIF, if available.
  final String? gifMini;

  /// Associated badges, if any.
  final List<HeypsterBadge>? badges;

  /// Associated emotions, if any.
  final List<HeypsterEmotion>? emotions;

  /// Associated tags, if any.
  final List<HeypsterTag>? tags;

  /// Creates a [HeypsterNativeGif] instance.
  const HeypsterNativeGif({
    required this.id,
    this.h265,
    this.h264,
    this.gifMini,
    this.badges,
    this.emotions,
    this.tags,
  });

  /// Full URL for the H265 MP4 video.
  Uri? get h265Url {
    if (h265 == null || h265!.isEmpty) return null;
    return Uri.parse('$_contentBaseUrl${h265!}');
  }

  /// Full URL for the H264 MP4 video.
  Uri? get h264Url {
    if (h264 == null || h264!.isEmpty) return null;
    return Uri.parse('$_contentBaseUrl${h264!}');
  }

  /// Full URL for the mini (240p) GIF.
  Uri? get gifMiniUrl {
    if (gifMini == null || gifMini!.isEmpty) return null;
    return Uri.parse('$_contentBaseUrl${gifMini!}');
  }

  /// Creates a [HeypsterNativeGif] from an API JSON response.
  factory HeypsterNativeGif.fromJson(Map<String, dynamic> json) {
    return HeypsterNativeGif(
      id: json['id'] as int,
      h265: json['h265'] as String?,
      h264: json['h264'] as String?,
      gifMini: json['gif_mini'] as String?,
      badges: (json['badges'] as List<dynamic>?)
          ?.map((b) => HeypsterBadge.fromJson(b as Map<String, dynamic>))
          .toList(),
      emotions: (json['emotions'] as List<dynamic>?)
          ?.map((e) {
            final emotionJson = e as Map<String, dynamic>;
            final emotionId = emotionJson['id'] as int;
            return HeypsterEmotion.fromId(emotionId);
          })
          .whereType<HeypsterEmotion>()
          .toList(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((t) => HeypsterTag.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts this native GIF to a [HeypsterMedia].
  ///
  /// Maps the H265 URL to the `original` rendition's mp4Url, and
  /// the gifMini URL to the `preview` rendition's gifUrl. Some
  /// rendition slots will be null since the native API provides
  /// fewer renditions than the GIPHY-compatible API.
  HeypsterMedia toHeypsterMedia() {
    final h265Uri = h265Url;
    final h264Uri = h264Url;
    final miniUri = gifMiniUrl;

    // Use H265 preferably, fall back to H264
    final videoUrl = h265Uri?.toString() ?? h264Uri?.toString();

    final originalImage = HeypsterImage(
      mp4Url: videoUrl,
      gifUrl: miniUri?.toString(),
    );

    final previewImage = HeypsterImage(gifUrl: miniUri?.toString());

    // Populate common renditions so HeypsterMediaView works
    // regardless of which renditionType the consumer picks.
    return HeypsterMedia(
      id: id.toString(),
      title: tags?.firstOrNull?.formatted,
      images: HeypsterImages(
        original: originalImage,
        fixedWidth: originalImage,
        fixedHeight: originalImage,
        fixedWidthSmall: originalImage,
        fixedHeightSmall: originalImage,
        downsized: originalImage,
        preview: previewImage,
      ),
      tags: tags?.map((t) => t.tag).toList(),
      aspectRatio: 1.75,
    );
  }

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'h265': h265,
    'h264': h264,
    'gif_mini': gifMini,
    'badges': badges?.map((b) => b.toJson()).toList(),
    'emotions': emotions?.map((e) => {'id': e.id}).toList(),
    'tags': tags?.map((t) => t.toJson()).toList(),
  };
}
