import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:heypster_flutter_sdk/src/cache/heypster_cache.dart';
import 'package:heypster_flutter_sdk/src/net/giphy_api_service.dart';
import 'package:heypster_flutter_sdk/src/net/native_api_service.dart';

void main() {
  group('HeypsterCache (unit)', () {
    late HeypsterCache cache;

    setUp(() => cache = HeypsterCache());

    test('get returns null for missing key', () {
      expect(cache.get<String>('missing'), isNull);
    });

    test('set and get round-trips', () {
      cache.set('key', 'value');
      expect(cache.get<String>('key'), 'value');
    });

    test('get returns null for expired entry', () {
      cache.set('key', 'value', ttl: Duration.zero);
      // Entry is immediately expired
      expect(cache.get<String>('key'), isNull);
    });

    test('containsKey returns false for expired entry', () {
      cache.set('key', 'value', ttl: Duration.zero);
      expect(cache.containsKey('key'), isFalse);
    });

    test('clear removes all entries', () {
      cache.set('a', 1);
      cache.set('b', 2);
      expect(cache.length, 2);
      cache.clear();
      expect(cache.length, 0);
      expect(cache.get<int>('a'), isNull);
    });

    test('remove deletes specific entry', () {
      cache.set('a', 1);
      cache.set('b', 2);
      cache.remove('a');
      expect(cache.get<int>('a'), isNull);
      expect(cache.get<int>('b'), 2);
    });

    test('evicts LRU entry when full', () {
      final small = HeypsterCache(maxEntries: 2);
      small.set('first', 1);
      small.set('second', 2);
      small.set('third', 3); // evicts 'first'
      expect(small.get<int>('first'), isNull);
      expect(small.get<int>('second'), 2);
      expect(small.get<int>('third'), 3);
    });

    test('accessing entry refreshes its position (LRU)', () {
      final small = HeypsterCache(maxEntries: 2);
      small.set('first', 1);
      small.set('second', 2);
      // Access 'first' to make it recently used
      small.get<int>('first');
      small.set('third', 3); // should evict 'second', not 'first'
      expect(small.get<int>('first'), 1);
      expect(small.get<int>('second'), isNull);
      expect(small.get<int>('third'), 3);
    });

    test('get returns null for wrong type', () {
      cache.set('key', 42);
      expect(cache.get<String>('key'), isNull);
      expect(cache.get<int>('key'), 42);
    });

    test('stores and retrieves Map<String, dynamic>', () {
      final data = {'id': '42', 'title': 'test'};
      cache.set('json', data);
      final retrieved = cache.get<Map<String, dynamic>>('json');
      expect(retrieved, isNotNull);
      expect(retrieved!['id'], '42');
    });
  });

  group('GiphyApiService caching', () {
    test('second identical request is served from cache', () async {
      var requestCount = 0;
      final cache = HeypsterCache();
      final service = GiphyApiService(
        client: MockClient((req) async {
          requestCount++;
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': '1',
                  'type': 'gif',
                  'title': 'Test',
                  'images': {
                    'original': {'url': 'https://example.com/1.gif'},
                  },
                },
              ],
              'pagination': {'total_count': 1, 'count': 1, 'offset': 0},
            }),
            200,
          );
        }),
        apiKey: 'test-key',
        cache: cache,
      );

      // First request hits network
      final result1 = await service.trending();
      expect(result1.data.length, 1);
      expect(requestCount, 1);

      // Second identical request served from cache
      final result2 = await service.trending();
      expect(result2.data.length, 1);
      expect(requestCount, 1); // still 1 — no new network call
    });

    test('different parameters cause separate cache entries', () async {
      var requestCount = 0;
      final cache = HeypsterCache();
      final service = GiphyApiService(
        client: MockClient((req) async {
          requestCount++;
          return http.Response(
            jsonEncode({
              'data': [],
              'pagination': {'total_count': 0, 'count': 0, 'offset': 0},
            }),
            200,
          );
        }),
        apiKey: 'test-key',
        cache: cache,
      );

      await service.searchGifs('cats');
      await service.searchGifs('dogs');
      expect(requestCount, 2); // two different queries

      await service.searchGifs('cats'); // cached
      expect(requestCount, 2); // no new call
    });

    test('random() is never cached', () async {
      var requestCount = 0;
      final cache = HeypsterCache();
      final service = GiphyApiService(
        client: MockClient((req) async {
          requestCount++;
          return http.Response(
            jsonEncode({
              'data': {
                'id': '$requestCount',
                'type': 'gif',
                'images': {
                  'original': {'url': 'https://example.com/$requestCount.gif'},
                },
              },
            }),
            200,
          );
        }),
        apiKey: 'test-key',
        cache: cache,
      );

      await service.random();
      await service.random();
      expect(requestCount, 2); // both hit network
    });

    test('cache.clear() causes next request to hit network', () async {
      var requestCount = 0;
      final cache = HeypsterCache();
      final service = GiphyApiService(
        client: MockClient((req) async {
          requestCount++;
          return http.Response(
            jsonEncode({
              'data': [],
              'pagination': {'total_count': 0, 'count': 0, 'offset': 0},
            }),
            200,
          );
        }),
        apiKey: 'test-key',
        cache: cache,
      );

      await service.trending();
      expect(requestCount, 1);

      cache.clear();

      await service.trending();
      expect(requestCount, 2); // cache was cleared, hits network again
    });
  });

  group('NativeApiService caching', () {
    test('second identical request is served from cache', () async {
      var requestCount = 0;
      final cache = HeypsterCache();
      final service = NativeApiService(
        client: MockClient((req) async {
          requestCount++;
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 1,
                  'h265': 'uploads/1.mp4',
                  'h264': 'uploads/1_h264.mp4',
                  'gif_mini': 'uploads/1.gif',
                },
              ],
              'pagination': {
                'count': 1,
                'per_page': 20,
                'current_page': 1,
                'next_page_url': null,
              },
            }),
            200,
          );
        }),
        apiKey: 'test-key',
        cache: cache,
      );

      await service.fetchGifsOfTheDay(page: 1);
      expect(requestCount, 1);

      await service.fetchGifsOfTheDay(page: 1);
      expect(requestCount, 1); // cached

      await service.fetchGifsOfTheDay(page: 2);
      expect(requestCount, 2); // different page, new request
    });

    test('tag search results are cached', () async {
      var requestCount = 0;
      final cache = HeypsterCache();
      final service = NativeApiService(
        client: MockClient((req) async {
          requestCount++;
          return http.Response(
            jsonEncode([
              {'id': 1, 'tag': 'hello'},
            ]),
            200,
          );
        }),
        apiKey: 'test-key',
        cache: cache,
      );

      final result1 = await service.searchTags('hello', 'en');
      expect(result1.length, 1);
      expect(requestCount, 1);

      final result2 = await service.searchTags('hello', 'en');
      expect(result2.length, 1);
      expect(requestCount, 1); // cached

      await service.searchTags('hello', 'fr');
      expect(requestCount, 2); // different language, new request
    });
  });

  group('Cache policy behavior', () {
    test('shared cache instance between services', () async {
      var giphyCount = 0;
      var nativeCount = 0;
      final cache = HeypsterCache();

      final giphyService = GiphyApiService(
        client: MockClient((req) async {
          giphyCount++;
          return http.Response(
            jsonEncode({
              'data': [],
              'pagination': {'total_count': 0, 'count': 0, 'offset': 0},
            }),
            200,
          );
        }),
        apiKey: 'key',
        cache: cache,
      );

      final nativeService = NativeApiService(
        client: MockClient((req) async {
          nativeCount++;
          return http.Response(
            jsonEncode({
              'data': [],
              'pagination': {'count': 0, 'per_page': 20, 'current_page': 1},
            }),
            200,
          );
        }),
        apiKey: 'key',
        cache: cache,
      );

      await giphyService.trending();
      await nativeService.fetchGifsOfTheDay();
      expect(giphyCount, 1);
      expect(nativeCount, 1);
      expect(cache.length, 2);

      // Clearing cache affects both services
      cache.clear();
      expect(cache.length, 0);

      await giphyService.trending();
      await nativeService.fetchGifsOfTheDay();
      expect(giphyCount, 2);
      expect(nativeCount, 2);
    });
  });
}
