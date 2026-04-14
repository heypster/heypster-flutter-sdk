import 'package:flutter_test/flutter_test.dart';
import 'package:heypster_flutter_sdk/heypster_flutter_sdk.dart';
import 'package:heypster_flutter_sdk/src/dto/heypster_native_gif.dart';
import 'package:heypster_flutter_sdk/src/net/heypster_client.dart';

void main() {
  group('HeypsterFlutterSDK', () {
    tearDown(() => HeypsterFlutterSDK.reset());

    test('configure stores configuration', () {
      HeypsterFlutterSDK.configure(apiKey: 'test-key');
      expect(HeypsterFlutterSDK.isConfigured, isTrue);
      expect(HeypsterFlutterSDK.config.apiKey, 'test-key');
    });

    test('config defaults are sensible', () {
      HeypsterFlutterSDK.configure(apiKey: 'test-key');
      final config = HeypsterFlutterSDK.config;
      expect(config.cachePolicy, HeypsterCachePolicy.clearOnDismiss);
      expect(config.gifQuality, HeypsterGifQuality.mini);
      expect(config.language, HeypsterLanguage.english);
    });

    test('config throws when not configured', () {
      expect(
        () => HeypsterFlutterSDK.config,
        throwsA(isA<HeypsterNotConfiguredError>()),
      );
    });

    test('dispose resets configuration', () {
      HeypsterFlutterSDK.configure(apiKey: 'test-key');
      expect(HeypsterFlutterSDK.isConfigured, isTrue);
      // Use reset() in tests to avoid triggering cache manager
      // bindings. The public dispose() calls reset() internally.
      HeypsterFlutterSDK.reset();
      HeypsterClient.reset();
      expect(HeypsterFlutterSDK.isConfigured, isFalse);
    });

    test('configure with custom values', () {
      HeypsterFlutterSDK.configure(
        apiKey: 'key',
        cachePolicy: HeypsterCachePolicy.alwaysPersist,
        gifQuality: HeypsterGifQuality.full,
        language: HeypsterLanguage.french,
      );
      final config = HeypsterFlutterSDK.config;
      expect(config.cachePolicy, HeypsterCachePolicy.alwaysPersist);
      expect(config.gifQuality, HeypsterGifQuality.full);
      expect(config.language, HeypsterLanguage.french);
    });
  });

  group('HeypsterEmotion', () {
    test('has correct IDs', () {
      expect(HeypsterEmotion.laughing.id, 2);
      expect(HeypsterEmotion.angry.id, 1);
      expect(HeypsterEmotion.please.id, 27);
    });

    test('fromId returns correct emotion', () {
      expect(HeypsterEmotion.fromId(2), HeypsterEmotion.laughing);
      expect(HeypsterEmotion.fromId(999), isNull);
    });

    test('selectableEmotions excludes swearing', () {
      expect(
        HeypsterEmotion.selectableEmotions,
        isNot(contains(HeypsterEmotion.swearing)),
      );
      expect(HeypsterEmotion.selectableEmotions.length, 26);
    });
  });

  group('HeypsterLanguage', () {
    test('fromCode returns correct language', () {
      expect(HeypsterLanguage.fromCode('fr'), HeypsterLanguage.french);
      expect(HeypsterLanguage.fromCode('xx'), isNull);
    });

    test('has 11 languages', () {
      expect(HeypsterLanguage.values.length, 11);
    });
  });

  group('HeypsterRating', () {
    test('round-trips through string conversion', () {
      for (final rating in HeypsterRating.values) {
        final str = HeypsterRatingExtension.toStringValue(rating);
        final parsed = HeypsterRatingExtension.fromStringValue(str);
        expect(parsed, rating);
      }
    });

    test('pg-13 alias works', () {
      expect(
        HeypsterRatingExtension.fromStringValue('pg-13'),
        HeypsterRating.pg13,
      );
      expect(
        HeypsterRatingExtension.fromStringValue('pg13'),
        HeypsterRating.pg13,
      );
    });
  });

  group('HeypsterRendition', () {
    test('toJsonKey returns snake_case', () {
      expect(
        HeypsterRenditionUtil.toJsonKey(HeypsterRendition.fixedWidth),
        'fixed_width',
      );
      expect(
        HeypsterRenditionUtil.toJsonKey(HeypsterRendition.original),
        'original',
      );
    });

    test('fromJsonKey round-trips', () {
      for (final r in HeypsterRendition.values) {
        final key = HeypsterRenditionUtil.toJsonKey(r);
        expect(HeypsterRenditionUtil.fromJsonKey(key), r);
      }
    });
  });

  group('HeypsterImage', () {
    test('fromJson parses API response', () {
      final json = {
        'url': 'https://example.com/gif.gif',
        'width': '200',
        'height': '150',
        'size': '12345',
        'mp4': 'https://example.com/gif.mp4',
        'mp4_size': '5000',
        'webp': 'https://example.com/gif.webp',
        'webp_size': '3000',
        'frames': '10',
      };
      final image = HeypsterImage.fromJson(json);
      expect(image.gifUrl, 'https://example.com/gif.gif');
      expect(image.mp4Url, 'https://example.com/gif.mp4');
      expect(image.webPUrl, 'https://example.com/gif.webp');
      expect(image.width, 200);
      expect(image.height, 150);
      expect(image.gifSize, 12345);
      expect(image.mp4Size, 5000);
      expect(image.frames, 10);
    });

    test('bestUrl prefers mp4', () {
      const image = HeypsterImage(
        gifUrl: 'gif.gif',
        mp4Url: 'gif.mp4',
        webPUrl: 'gif.webp',
      );
      expect(image.bestUrl, 'gif.mp4');
    });

    test('bestUrl falls back to webp then gif', () {
      const withWebp = HeypsterImage(gifUrl: 'gif.gif', webPUrl: 'gif.webp');
      expect(withWebp.bestUrl, 'gif.webp');

      const gifOnly = HeypsterImage(gifUrl: 'gif.gif');
      expect(gifOnly.bestUrl, 'gif.gif');
    });

    test('toJson round-trips', () {
      final original = {
        'url': 'https://example.com/gif.gif',
        'width': 200,
        'height': 150,
        'size': 12345,
        'mp4': 'https://example.com/gif.mp4',
        'mp4_size': 5000,
        'webp': 'https://example.com/gif.webp',
        'webp_size': 3000,
        'frames': 10,
      };
      final image = HeypsterImage.fromJson(original);
      final json = image.toJson();
      final roundTripped = HeypsterImage.fromJson(json);
      expect(roundTripped.gifUrl, image.gifUrl);
      expect(roundTripped.mp4Url, image.mp4Url);
      expect(roundTripped.width, image.width);
    });
  });

  group('HeypsterTag', () {
    test('formatted replaces dashes with spaces', () {
      const tag = HeypsterTag(id: 1, tag: 'thank-you');
      expect(tag.formatted, 'thank you');
    });

    test('fromJson parses correctly', () {
      final tag = HeypsterTag.fromJson({'id': 42, 'tag': 'hello-world'});
      expect(tag.id, 42);
      expect(tag.tag, 'hello-world');
      expect(tag.formatted, 'hello world');
    });

    test('hashCode uses Object.hash', () {
      final a = const HeypsterTag(id: 1, tag: 'hello');
      final b = const HeypsterTag(id: 1, tag: 'hello');
      expect(a.hashCode, b.hashCode);
    });
  });

  group('HeypsterNativeGif', () {
    test('fromJson parses correctly', () {
      final gif = HeypsterNativeGif.fromJson({
        'id': 123,
        'h265': 'uploads/123.mp4',
        'gif_mini': 'uploads/123_mini.gif',
        'tags': [
          {'id': 1, 'tag': 'hello'},
        ],
        'emotions': [
          {'id': 2},
        ],
      });
      expect(gif.id, 123);
      expect(gif.h265, 'uploads/123.mp4');
      expect(gif.tags?.length, 1);
      expect(gif.emotions?.first, HeypsterEmotion.laughing);
    });

    test('toHeypsterMedia bridges correctly', () {
      final gif = HeypsterNativeGif(
        id: 42,
        h265: 'uploads/42.mp4',
        gifMini: 'uploads/42_mini.gif',
        tags: const [HeypsterTag(id: 1, tag: 'test')],
      );
      final media = gif.toHeypsterMedia();
      expect(media.id, '42');
      expect(media.aspectRatio, 1.75);
      expect(
        media.images.original?.mp4Url,
        'https://heypster-gif.com/uploads/42.mp4',
      );
      expect(
        media.images.preview?.gifUrl,
        'https://heypster-gif.com/uploads/42_mini.gif',
      );
    });

    test('h265Url builds correct URL', () {
      const gif = HeypsterNativeGif(id: 1, h265: 'uploads/1.mp4');
      expect(gif.h265Url.toString(), 'https://heypster-gif.com/uploads/1.mp4');
    });

    test('h265Url returns null when h265 is null', () {
      const gif = HeypsterNativeGif(id: 1);
      expect(gif.h265, isNull);
      expect(gif.h265Url, isNull);
    });
  });

  group('HeypsterMedia', () {
    test('fromJson parses GIPHY-compatible response', () {
      final json = {
        'id': 'abc123',
        'type': 'gif',
        'slug': 'funny-abc123',
        'url': 'https://heypster-gif.com/gifs/abc123',
        'title': 'Funny GIF',
        'rating': 'g',
        'tags': ['funny', 'cat'],
        'images': {
          'original': {
            'url': 'https://example.com/original.gif',
            'width': '480',
            'height': '270',
            'mp4': 'https://example.com/original.mp4',
          },
          'fixed_width': {
            'url': 'https://example.com/fixed.gif',
            'width': '200',
            'height': '113',
          },
        },
      };
      final media = HeypsterMedia.fromJson(json);
      expect(media.id, 'abc123');
      expect(media.type, HeypsterMediaType.gif);
      expect(media.title, 'Funny GIF');
      expect(media.rating, HeypsterRating.g);
      expect(media.tags, ['funny', 'cat']);
      expect(media.images.original?.gifUrl, isNotNull);
      expect(media.images.fixedWidth?.gifUrl, isNotNull);
      expect(media.aspectRatio, closeTo(480 / 270, 0.01));
    });

    test('fromJson ignores non-string tags', () {
      final media = HeypsterMedia.fromJson(<String, dynamic>{
        'id': 'test',
        'images': <String, dynamic>{},
        'tags': ['valid', 42, null, 'also-valid'],
      });
      expect(media.tags, ['valid', 'also-valid']);
    });
  });

  group('HeypsterContentRequest', () {
    test('search factory', () {
      final req = HeypsterContentRequest.search(searchQuery: 'cats');
      expect(req.requestType, HeypsterContentRequestType.search);
      expect(req.searchQuery, 'cats');
      expect(req.mediaType, HeypsterMediaType.gif);
    });

    test('trendingGifs factory', () {
      final req = HeypsterContentRequest.trendingGifs();
      expect(req.requestType, HeypsterContentRequestType.trending);
      expect(req.mediaType, HeypsterMediaType.gif);
    });

    test('byEmotion factory', () {
      final req = HeypsterContentRequest.byEmotion(HeypsterEmotion.happy);
      expect(req.requestType, HeypsterContentRequestType.byEmotion);
      expect(req.emotion, HeypsterEmotion.happy);
    });

    test('emoji factory', () {
      final req = HeypsterContentRequest.emoji();
      expect(req.requestType, HeypsterContentRequestType.emoji);
      expect(req.mediaType, HeypsterMediaType.emoji);
    });
  });

  group('HeypsterSettings', () {
    test('defaults are correct', () {
      const settings = HeypsterSettings();
      expect(settings.rating, HeypsterRating.pg13);
      expect(settings.showEmotions, isTrue);
      expect(settings.fileFormat, HeypsterFileFormat.mp4);
      expect(settings.mediaTypeConfig, [
        HeypsterContentType.gif,
        HeypsterContentType.emoji,
      ]);
    });

    test('copyWith replaces values', () {
      const settings = HeypsterSettings();
      final updated = settings.copyWith(
        rating: HeypsterRating.g,
        showEmotions: false,
      );
      expect(updated.rating, HeypsterRating.g);
      expect(updated.showEmotions, isFalse);
      expect(updated.fileFormat, HeypsterFileFormat.mp4);
    });
  });

  group('HeypsterImages', () {
    test('imageFor returns correct rendition', () {
      const images = HeypsterImages(
        original: HeypsterImage(gifUrl: 'original.gif'),
        fixedWidth: HeypsterImage(gifUrl: 'fixed.gif'),
      );
      expect(
        images.imageFor(HeypsterRendition.original)?.gifUrl,
        'original.gif',
      );
      expect(
        images.imageFor(HeypsterRendition.fixedWidth)?.gifUrl,
        'fixed.gif',
      );
      expect(images.imageFor(HeypsterRendition.preview), isNull);
    });
  });
}
