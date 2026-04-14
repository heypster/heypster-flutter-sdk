import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:heypster_flutter_sdk/heypster_flutter_sdk.dart';
import 'package:heypster_flutter_sdk/src/cache/heypster_cache.dart';
import 'package:heypster_flutter_sdk/src/net/native_api_service.dart';

void main() {
  late NativeApiService service;

  NativeApiService createService(http.Response Function(http.Request) handler) {
    return NativeApiService(
      client: MockClient((req) async => handler(req)),
      apiKey: 'test-native-key',
      cache: HeypsterCache(),
    );
  }

  group('authentication', () {
    test('sends HEYPSTER-API-KEY header', () async {
      String? capturedHeader;
      service = createService((req) {
        capturedHeader = req.headers['HEYPSTER-API-KEY'];
        return http.Response(
          jsonEncode({
            'data': [],
            'pagination': {'count': 0, 'per_page': 20, 'current_page': 1},
          }),
          200,
        );
      });

      await service.fetchGifsOfTheDay();
      expect(capturedHeader, 'test-native-key');
    });
  });

  group('fetchGifsOfTheDay', () {
    test('sends correct page parameter', () async {
      String? capturedPage;
      service = createService((req) {
        capturedPage = req.url.queryParameters['page'];
        return http.Response(
          jsonEncode({
            'data': [],
            'pagination': {'count': 0, 'per_page': 20, 'current_page': 2},
          }),
          200,
        );
      });

      await service.fetchGifsOfTheDay(page: 2);
      expect(capturedPage, '2');
    });

    test('parses native GIF response', () async {
      service = createService((_) {
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 34093,
                'gif_mini': 'uploads/gifs-mini/2025/11/test.gif',
                'h265': 'uploads/h265/2025/11/test.mp4',
                'h264': 'uploads/h264/2025/11/test.mp4',
              },
              {
                'id': 32826,
                'gif_mini': 'uploads/gifs-mini/2025/09/test2.gif',
                'h265': 'uploads/h265/2025/09/test2.mp4',
                'h264': 'uploads/h264/2025/09/test2.mp4',
              },
            ],
            'pagination': {
              'count': 2,
              'per_page': 20,
              'current_page': 1,
              'next_page_url': 'http://heypster-gif.com/sdk/gifs?page=2',
            },
          }),
          200,
        );
      });

      final result = await service.fetchGifsOfTheDay();
      expect(result.data.length, 2);
      expect(result.data.first.id, 34093);
      expect(result.data.first.h264, isNotNull);
      expect(result.hasNextPage, isTrue);
      expect(result.pagination.currentPage, 1);
      expect(result.pagination.perPage, 20);
    });
  });

  group('fetchGifsByEmotion', () {
    test('sends correct emotion ID in path', () async {
      String? capturedPath;
      service = createService((req) {
        capturedPath = req.url.path;
        return http.Response(
          jsonEncode({
            'data': [],
            'pagination': {'count': 0, 'per_page': 20, 'current_page': 1},
          }),
          200,
        );
      });

      await service.fetchGifsByEmotion(2, page: 1);
      expect(capturedPath, contains('/gifs-emotions/2'));
    });
  });

  group('fetchGifsByTag', () {
    test('sends correct tag ID in path', () async {
      String? capturedPath;
      service = createService((req) {
        capturedPath = req.url.path;
        return http.Response(
          jsonEncode({
            'data': [],
            'pagination': {'count': 0, 'per_page': 20, 'current_page': 1},
          }),
          200,
        );
      });

      await service.fetchGifsByTag(892);
      expect(capturedPath, contains('/gifs-tags/892'));
    });
  });

  group('searchTags', () {
    test('sends input and language in path', () async {
      String? capturedPath;
      service = createService((req) {
        capturedPath = req.url.path;
        return http.Response(jsonEncode([]), 200);
      });

      await service.searchTags('hello', 'fr');
      expect(capturedPath, contains('/tags/hello/fr'));
    });

    test('parses bare array response', () async {
      service = createService((_) {
        return http.Response(
          jsonEncode([
            {'id': 892, 'tag': 'hello'},
            {'id': 893, 'tag': 'hello-world'},
          ]),
          200,
        );
      });

      final tags = await service.searchTags('hello', 'en');
      expect(tags.length, 2);
      expect(tags.first.id, 892);
      expect(tags.first.tag, 'hello');
      expect(tags.last.tag, 'hello-world');
    });

    test('returns empty list on empty response', () async {
      service = createService((_) {
        return http.Response(jsonEncode([]), 200);
      });

      final tags = await service.searchTags('xyz', 'en');
      expect(tags, isEmpty);
    });
  });

  group('pagination', () {
    test('hasNextPage is false when no next URL', () async {
      service = createService((_) {
        return http.Response(
          jsonEncode({
            'data': [],
            'pagination': {
              'count': 5,
              'per_page': 20,
              'current_page': 1,
              'next_page_url': null,
            },
          }),
          200,
        );
      });

      final result = await service.fetchGifsOfTheDay();
      expect(result.hasNextPage, isFalse);
    });
  });

  group('error handling', () {
    test('throws HeypsterRequestError on 403', () async {
      service = createService((_) {
        return http.Response(jsonEncode({'message': 'API key invalid'}), 403);
      });

      expect(
        () => service.fetchGifsOfTheDay(),
        throwsA(
          isA<HeypsterRequestError>().having(
            (e) => e.statusCode,
            'statusCode',
            403,
          ),
        ),
      );
    });

    test('throws HeypsterRequestError on network error', () async {
      service = NativeApiService(
        client: MockClient((_) async => throw Exception('offline')),
        apiKey: 'key',
        cache: HeypsterCache(),
      );

      expect(
        () => service.fetchGifsOfTheDay(),
        throwsA(isA<HeypsterRequestError>()),
      );
    });
  });
}
