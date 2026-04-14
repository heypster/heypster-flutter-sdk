import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:heypster_flutter_sdk/heypster_flutter_sdk.dart';
import 'package:heypster_flutter_sdk/src/cache/heypster_cache.dart';
import 'package:heypster_flutter_sdk/src/net/giphy_api_service.dart';

void main() {
  late GiphyApiService service;

  GiphyApiService createService(http.Response Function(http.Request) handler) {
    return GiphyApiService(
      client: MockClient((req) async => handler(req)),
      apiKey: 'test-key',
      cache: HeypsterCache(),
    );
  }

  group('authentication', () {
    test('sends api_key as query parameter', () async {
      String? capturedApiKey;
      service = createService((req) {
        capturedApiKey = req.url.queryParameters['api_key'];
        return http.Response(
          jsonEncode({
            'data': [],
            'pagination': {'total_count': 0, 'count': 0, 'offset': 0},
            'meta': {'status': 200, 'msg': 'OK'},
          }),
          200,
        );
      });
      await service.trending();
      expect(capturedApiKey, 'test-key');
    });
  });

  group('searchGifs', () {
    test('sends correct query parameters', () async {
      Uri? capturedUri;
      service = createService((req) {
        capturedUri = req.url;
        return http.Response(
          jsonEncode({
            'data': [],
            'pagination': {'total_count': 0, 'count': 0, 'offset': 0},
          }),
          200,
        );
      });

      await service.searchGifs(
        'cats',
        limit: 10,
        offset: 5,
        lang: 'fr',
        rating: HeypsterRating.g,
      );

      expect(capturedUri!.queryParameters['q'], 'cats');
      expect(capturedUri!.queryParameters['limit'], '10');
      expect(capturedUri!.queryParameters['offset'], '5');
      expect(capturedUri!.queryParameters['lang'], 'fr');
      expect(capturedUri!.queryParameters['rating'], 'g');
    });

    test('parses paginated media response', () async {
      service = createService((_) {
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': '42',
                'type': 'gif',
                'title': 'Test GIF',
                'images': {
                  'original': {
                    'url': 'https://example.com/gif.gif',
                    'mp4': 'https://example.com/gif.mp4',
                    'width': '480',
                    'height': '270',
                  },
                },
              },
            ],
            'pagination': {'total_count': 100, 'count': 1, 'offset': 0},
          }),
          200,
        );
      });

      final result = await service.searchGifs('test');
      expect(result.data.length, 1);
      expect(result.data.first.id, '42');
      expect(result.data.first.title, 'Test GIF');
      expect(result.totalCount, 100);
      expect(result.count, 1);
      expect(result.offset, 0);
    });
  });

  group('random', () {
    test('parses single object (not array)', () async {
      service = createService((_) {
        return http.Response(
          jsonEncode({
            'data': {
              'id': '99',
              'type': 'gif',
              'title': 'Random GIF',
              'images': {
                'original': {'url': 'https://example.com/r.gif'},
              },
            },
          }),
          200,
        );
      });

      final result = await service.random();
      expect(result, isNotNull);
      expect(result!.id, '99');
      expect(result.title, 'Random GIF');
    });

    test('returns null for empty data', () async {
      service = createService((_) {
        return http.Response(jsonEncode({'data': {}}), 200);
      });

      final result = await service.random();
      expect(result, isNull);
    });
  });

  group('getById', () {
    test('fetches single GIF', () async {
      String? capturedPath;
      service = createService((req) {
        capturedPath = req.url.path;
        return http.Response(
          jsonEncode({
            'data': {
              'id': '57',
              'type': 'gif',
              'images': {
                'original': {'url': 'https://example.com/57.gif'},
              },
            },
          }),
          200,
        );
      });

      final result = await service.getById('57');
      expect(capturedPath, contains('/v1/gifs/57'));
      expect(result?.id, '57');
    });
  });

  group('getByIds', () {
    test('sends comma-separated IDs', () async {
      String? capturedIds;
      service = createService((req) {
        capturedIds = req.url.queryParameters['ids'];
        return http.Response(jsonEncode({'data': []}), 200);
      });

      await service.getByIds(['1', '2', '3']);
      expect(capturedIds, '1,2,3');
    });
  });

  group('error handling', () {
    test('throws HeypsterRequestError on non-200', () async {
      service = createService((_) {
        return http.Response('{"error": "not found"}', 404);
      });

      expect(
        () => service.trending(),
        throwsA(
          isA<HeypsterRequestError>().having(
            (e) => e.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    });

    test('throws HeypsterDecodingError on invalid JSON', () async {
      service = createService((_) {
        return http.Response('not json', 200);
      });

      expect(() => service.trending(), throwsA(isA<HeypsterDecodingError>()));
    });

    test('throws HeypsterRequestError on network error', () async {
      service = GiphyApiService(
        client: MockClient((_) async => throw Exception('no network')),
        apiKey: 'key',
        cache: HeypsterCache(),
      );

      expect(() => service.trending(), throwsA(isA<HeypsterRequestError>()));
    });
  });
}
