import 'package:video_player/video_player.dart';

/// A controller for managing playback in a [HeypsterMediaView].
///
/// Attach this controller to a [HeypsterMediaView] via its
/// `controller` parameter to gain imperative control over
/// playback.
///
/// ```dart
/// final controller = HeypsterMediaViewController();
///
/// HeypsterMediaView(
///   media: myMedia,
///   controller: controller,
/// );
///
/// // Later:
/// await controller.pause();
/// await controller.resume();
/// ```
class HeypsterMediaViewController {
  VideoPlayerController? _videoController;

  /// Attaches the underlying video controller.
  void attach(VideoPlayerController controller) {
    _videoController = controller;
  }

  /// Detaches the underlying video controller.
  void detach() {
    _videoController = null;
  }

  /// Pauses playback.
  Future<void> pause() async => _videoController?.pause();

  /// Resumes playback.
  Future<void> resume() async => _videoController?.play();
}
