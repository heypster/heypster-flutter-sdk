import 'package:flutter_test/flutter_test.dart';
import 'package:heypster_flutter_sdk/heypster_flutter_sdk.dart';

void main() {
  group('HeypsterMediaView', () {
    test('constructor accepts all parameters', () {
      // Verify the widget can be instantiated with all params
      final controller = HeypsterMediaViewController();
      const media = HeypsterMedia(
        id: '1',
        images: HeypsterImages(
          fixedWidth: HeypsterImage(
            mp4Url: 'https://example.com/test.mp4',
            gifUrl: 'https://example.com/test.gif',
          ),
        ),
      );

      final widget = HeypsterMediaView(
        media: media,
        autoPlay: false,
        renditionType: HeypsterRendition.fixedWidth,
        resizeMode: HeypsterResizeMode.contain,
        controller: controller,
        onError: (desc) {},
      );

      expect(widget.media, media);
      expect(widget.autoPlay, isFalse);
      expect(widget.renditionType, HeypsterRendition.fixedWidth);
      expect(widget.resizeMode, HeypsterResizeMode.contain);
      expect(widget.controller, controller);
    });

    test('defaults match Giphy pattern', () {
      const widget = HeypsterMediaView();

      expect(widget.autoPlay, isTrue);
      expect(widget.renditionType, HeypsterRendition.fixedWidth);
      expect(widget.resizeMode, HeypsterResizeMode.cover);
      expect(widget.controller, isNull);
      expect(widget.onError, isNull);
    });

    test('accepts mediaId without media', () {
      const widget = HeypsterMediaView(mediaId: '42');

      expect(widget.mediaId, '42');
      expect(widget.media, isNull);
    });
  });

  group('HeypsterMediaViewController', () {
    test('pause and resume are safe when detached', () async {
      final controller = HeypsterMediaViewController();
      // Should not throw when no video controller is attached
      await controller.pause();
      await controller.resume();
    });
  });

  group('URL selection logic', () {
    test('prefers mp4Url from rendition via HeypsterImage.bestUrl', () {
      const image = HeypsterImage(
        mp4Url: 'https://example.com/video.mp4',
        gifUrl: 'https://example.com/fallback.gif',
      );
      expect(image.bestUrl, 'https://example.com/video.mp4');
    });

    test('falls back to gifUrl when mp4Url is null', () {
      const image = HeypsterImage(gifUrl: 'https://example.com/fallback.gif');
      expect(image.bestUrl, 'https://example.com/fallback.gif');
    });

    test('returns null when no URLs available', () {
      const image = HeypsterImage();
      expect(image.bestUrl, isNull);
    });
  });
}
