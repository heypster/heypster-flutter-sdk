import 'package:meta/meta.dart';

import 'heypster_rendition.dart';

/// A single image rendition with URLs and dimensions.
///
/// Each rendition may have GIF, MP4, and WebP versions available.
/// Prefer [mp4Url] over [gifUrl] for playback — video is far more
/// efficient in both bandwidth and CPU than animated GIF.
@immutable
class HeypsterImage {
  /// The URL of the GIF version.
  final String? gifUrl;

  /// The width in pixels.
  final int width;

  /// The height in pixels.
  final int height;

  /// The size of the GIF in bytes.
  final int gifSize;

  /// The number of frames in the GIF.
  final int frames;

  /// The URL of the MP4 version.
  final String? mp4Url;

  /// The size of the MP4 in bytes.
  final int mp4Size;

  /// The URL of the WebP version.
  final String? webPUrl;

  /// The size of the WebP in bytes.
  final int webPSize;

  /// The media ID this image belongs to.
  final String? mediaId;

  /// The rendition type of this image.
  final HeypsterRendition? renditionType;

  /// Creates a [HeypsterImage] instance.
  const HeypsterImage({
    this.gifUrl,
    this.width = 0,
    this.height = 0,
    this.gifSize = 0,
    this.frames = 0,
    this.mp4Url,
    this.mp4Size = 0,
    this.webPUrl,
    this.webPSize = 0,
    this.mediaId,
    this.renditionType,
  });

  /// Creates a [HeypsterImage] from an API JSON response.
  ///
  /// The GIPHY-compatible API uses snake_case keys:
  /// `url`, `width`, `height`, `size`, `mp4`, `mp4_size`,
  /// `webp`, `webp_size`, `frames`.
  factory HeypsterImage.fromJson(Map<String, dynamic> json) {
    return HeypsterImage(
      gifUrl: json['url'] as String?,
      width: _parseInt(json['width']),
      height: _parseInt(json['height']),
      gifSize: _parseInt(json['size']),
      frames: _parseInt(json['frames']),
      mp4Url: json['mp4'] as String?,
      mp4Size: _parseInt(json['mp4_size']),
      webPUrl: json['webp'] as String?,
      webPSize: _parseInt(json['webp_size']),
      mediaId: json['media_id'] as String?,
      renditionType: json['rendition_type'] != null
          ? HeypsterRenditionUtil.fromStringValue(
              json['rendition_type'] as String,
            )
          : null,
    );
  }

  /// Converts this image to a JSON map.
  Map<String, dynamic> toJson() => {
    'url': gifUrl,
    'width': width,
    'height': height,
    'size': gifSize,
    'frames': frames,
    'mp4': mp4Url,
    'mp4_size': mp4Size,
    'webp': webPUrl,
    'webp_size': webPSize,
    'media_id': mediaId,
    if (renditionType != null)
      'rendition_type': HeypsterRenditionUtil.toStringValue(renditionType!),
  };

  /// The best URL for playback — prefers MP4, falls back to WebP,
  /// then GIF.
  String? get bestUrl => mp4Url ?? webPUrl ?? gifUrl;

  static int _parseInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
