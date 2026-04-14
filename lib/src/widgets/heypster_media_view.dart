import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../cache/heypster_media_cache.dart';
import '../dto/heypster_media.dart';
import '../l10n/generated/heypster_localizations.dart';
import '../dto/heypster_rendition.dart';
import '../dto/misc.dart';
import '../net/heypster_client.dart';
import 'heypster_media_view_controller.dart';

/// A widget for displaying a single heypster GIF.
///
/// Prefers MP4 video playback over animated GIF rendering for
/// better performance. Falls back to [Image.network] only when
/// no video URL is available.
///
/// Provide either [media] or [mediaId]. If [mediaId] is given
/// without [media], the widget fetches the media from the API.
///
/// ```dart
/// HeypsterMediaView(
///   media: selectedMedia,
///   renditionType: HeypsterRendition.fixedWidth,
/// )
/// ```
class HeypsterMediaView extends StatefulWidget {
  /// The media item to display.
  final HeypsterMedia? media;

  /// The ID of the media item to fetch and display.
  final String? mediaId;

  /// Whether to start playback automatically.
  final bool autoPlay;

  /// Which rendition to display.
  final HeypsterRendition renditionType;

  /// How to fit the content within its bounds.
  final HeypsterResizeMode resizeMode;

  /// Controller for imperative playback control.
  final HeypsterMediaViewController? controller;

  /// Called when an error occurs while loading or playing media.
  final void Function(String description)? onError;

  /// Creates a [HeypsterMediaView].
  const HeypsterMediaView({
    super.key,
    this.media,
    this.mediaId,
    this.autoPlay = true,
    this.renditionType = HeypsterRendition.fixedWidth,
    this.resizeMode = HeypsterResizeMode.cover,
    this.controller,
    this.onError,
  });

  @override
  State<HeypsterMediaView> createState() => _HeypsterMediaViewState();
}

class _HeypsterMediaViewState extends State<HeypsterMediaView> {
  HeypsterMedia? _media;
  VideoPlayerController? _videoController;
  File? _cachedImageFile;
  bool _isLoading = true;
  bool _hasError = false;
  bool _usesFallbackImage = false;

  @override
  void initState() {
    super.initState();
    _media = widget.media;
    _initMedia();
  }

  @override
  void didUpdateWidget(HeypsterMediaView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final mediaChanged =
        oldWidget.media?.id != widget.media?.id ||
        oldWidget.mediaId != widget.mediaId;
    final renditionChanged = oldWidget.renditionType != widget.renditionType;

    if (mediaChanged || renditionChanged) {
      _disposeVideo();
      _media = widget.media;
      _initMedia();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  void _disposeVideo() {
    widget.controller?.detach();
    _videoController?.dispose();
    _videoController = null;
  }

  Future<void> _initMedia() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _usesFallbackImage = false;
    });

    // Fetch media by ID if needed
    if (_media == null && widget.mediaId != null) {
      try {
        _media = await HeypsterClient.instance.giphyApi.getById(
          widget.mediaId!,
        );
      } catch (e) {
        _onError('Failed to fetch media: $e');
        return;
      }
    }

    if (!mounted) return;

    if (_media == null) {
      _onError('No media provided');
      return;
    }

    _initRendition();
  }

  Future<void> _initRendition() async {
    final image = _media!.images.imageFor(widget.renditionType);
    if (image == null) {
      _onError('Rendition not available');
      return;
    }

    // On Android/iOS, prefer animated GIF over video to avoid
    // MediaCodec decoder limits. Flutter's Image widget animates
    // GIFs natively without hardware decoders.
    final preferGif =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    if (preferGif && image.gifUrl != null && image.gifUrl!.isNotEmpty) {
      if (!kIsWeb) {
        _cachedImageFile = await HeypsterMediaCache.instance.getFile(
          image.gifUrl!,
        );
      }
      if (mounted) {
        setState(() {
          _usesFallbackImage = true;
          _isLoading = false;
        });
      }
      return;
    }

    // On desktop/web/iOS, use video (no decoder limits)
    final videoUrl = image.mp4Url;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _initVideo(videoUrl);
    } else if (image.gifUrl != null && image.gifUrl!.isNotEmpty) {
      // Final fallback to animated GIF on any platform
      if (!kIsWeb) {
        _cachedImageFile = await HeypsterMediaCache.instance.getFile(
          image.gifUrl!,
        );
      }
      if (mounted) {
        setState(() {
          _usesFallbackImage = true;
          _isLoading = false;
        });
      }
    } else {
      _onError('No playable URL in rendition');
    }
  }

  Future<void> _initVideo(String url) async {
    VideoPlayerController controller;

    // On native platforms, try to play from cached file
    if (!kIsWeb) {
      final cachedFile = await HeypsterMediaCache.instance.getFile(url);
      if (!mounted) return;
      if (cachedFile != null) {
        controller = VideoPlayerController.file(cachedFile);
      } else {
        controller = VideoPlayerController.networkUrl(Uri.parse(url));
      }
    } else {
      controller = VideoPlayerController.networkUrl(Uri.parse(url));
    }

    _videoController = controller;
    widget.controller?.attach(controller);

    try {
      await controller.initialize();

      // A newer _initVideo call may have replaced _videoController
      // while we were awaiting. If so, discard this stale controller.
      if (_videoController != controller) {
        controller.dispose();
        return;
      }

      controller.setLooping(true);
      controller.setVolume(0);

      if (mounted) {
        setState(() => _isLoading = false);
        if (widget.autoPlay) {
          controller.play();
        }
      }
    } catch (e) {
      // Only update state if this controller is still the active one.
      // A newer _initVideo may have already replaced it.
      if (_videoController == controller) {
        _videoController = null;
        widget.controller?.detach();
        _onError('Video initialization failed: $e');
      }
      controller.dispose();
    }
  }

  void _onError(String description) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
    widget.onError?.call(description);
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_videoController == null) return;
    if (info.visibleFraction == 0) {
      _videoController!.pause();
    } else if (widget.autoPlay) {
      _videoController!.play();
    }
  }

  BoxFit _boxFit() {
    switch (widget.resizeMode) {
      case HeypsterResizeMode.center:
        return BoxFit.none;
      case HeypsterResizeMode.contain:
        return BoxFit.contain;
      case HeypsterResizeMode.cover:
        return BoxFit.cover;
      case HeypsterResizeMode.stretch:
        return BoxFit.fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_hasError) {
      final l10n = HeypsterLocalizations.of(context);
      return Center(
        child: IconButton(
          onPressed: () {
            _disposeVideo();
            _media = widget.media;
            _initMedia();
          },
          icon: const Icon(Icons.refresh),
          tooltip: l10n?.retry ?? 'Retry',
        ),
      );
    }

    final semanticLabel = _media?.altText ?? _media?.title ?? 'GIF';
    final failedLabel =
        HeypsterLocalizations.of(context)?.failedToLoadImage ??
        'Failed to load image';

    if (_usesFallbackImage) {
      final image = _media?.images.imageFor(widget.renditionType);
      final url = image?.gifUrl;
      if (image == null || url == null) {
        return const SizedBox.shrink();
      }

      // On native, try to show from disk cache
      if (!kIsWeb && _cachedImageFile != null) {
        return Image.file(
          _cachedImageFile!,
          fit: _boxFit(),
          semanticLabel: semanticLabel,
          errorBuilder: (_, error, _) {
            _onError('Image load failed: $error');
            return Icon(Icons.broken_image, semanticLabel: failedLabel);
          },
        );
      }

      return Image.network(
        url,
        fit: _boxFit(),
        semanticLabel: semanticLabel,
        errorBuilder: (_, error, _) {
          _onError('Image load failed: $error');
          return Icon(Icons.broken_image, semanticLabel: failedLabel);
        },
      );
    }

    if (_videoController != null && _videoController!.value.isInitialized) {
      return VisibilityDetector(
        key: Key('heypster_media_${_media?.id ?? hashCode}'),
        onVisibilityChanged: _onVisibilityChanged,
        child: Semantics(
          label: semanticLabel,
          image: true,
          child: FittedBox(
            fit: _boxFit(),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: IgnorePointer(child: VideoPlayer(_videoController!)),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
