import 'dart:convert';

import 'package:http/http.dart' as http;

import '../cache/heypster_cache.dart';
import '../dto/heypster_error.dart';
import '../dto/heypster_media.dart';
import '../dto/heypster_rating.dart';
import 'api_constants.dart';
import 'heypster_paginated_response.dart';
import 'retry.dart';

/// Service for the GIPHY-compatible heypster API.
///
/// All endpoints use query parameter authentication (`api_key`).
/// Responses are cached in-memory via [HeypsterCache] — identical
/// requests within the TTL window are served from cache.
class GiphyApiService {
  final http.Client _client;
  final String _apiKey;
  final HeypsterCache _cache;

  GiphyApiService({
    required http.Client client,
    required String apiKey,
    required HeypsterCache cache,
  }) : _client = client,
       _apiKey = apiKey,
       _cache = cache;

  /// Search for GIFs matching a text query.
  Future<HeypsterPaginatedResponse<HeypsterMedia>> searchGifs(
    String query, {
    int limit = ApiConstants.defaultLimit,
    int offset = 0,
    String? lang,
    HeypsterRating? rating,
  }) async {
    final params = {
      'q': query,
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (lang != null) 'lang': lang,
      if (rating != null)
        'rating': HeypsterRatingExtension.toStringValue(rating),
    };
    return _fetchPaginatedMedia('/v1/gifs/search', params);
  }

  /// Fetch trending GIFs.
  Future<HeypsterPaginatedResponse<HeypsterMedia>> trending({
    int limit = ApiConstants.defaultLimit,
    int offset = 0,
    HeypsterRating? rating,
  }) async {
    final params = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (rating != null)
        'rating': HeypsterRatingExtension.toStringValue(rating),
    };
    return _fetchPaginatedMedia('/v1/gifs/trending', params);
  }

  /// Translate a phrase to a single GIF.
  Future<HeypsterMedia?> translate(String term, {int? weirdness}) async {
    final params = {
      's': term,
      if (weirdness != null) 'weirdness': weirdness.toString(),
    };
    final json = await _get('/v1/gifs/translate', params);
    final data = json['data'];
    if (data == null || (data is Map && data.isEmpty)) return null;
    return HeypsterMedia.fromJson(data as Map<String, dynamic>);
  }

  /// Fetch a random GIF.
  ///
  /// This endpoint is **never cached** — each call returns a
  /// different result.
  Future<HeypsterMedia?> random({String? tag, HeypsterRating? rating}) async {
    final params = {
      if (tag != null) 'tag': tag,
      if (rating != null)
        'rating': HeypsterRatingExtension.toStringValue(rating),
    };
    // Skip cache — random must always be fresh
    final json = await _getFromNetwork('/v1/gifs/random', params);
    final data = json['data'];
    if (data == null || (data is Map && data.isEmpty)) return null;
    return HeypsterMedia.fromJson(data as Map<String, dynamic>);
  }

  /// Fetch a single GIF by ID.
  ///
  /// Cached for 30 minutes — GIF metadata is immutable.
  Future<HeypsterMedia?> getById(String id) async {
    final json = await _get(
      '/v1/gifs/$id',
      {},
      ttl: const Duration(minutes: 30),
    );
    final data = json['data'];
    if (data == null || (data is Map && data.isEmpty)) return null;
    return HeypsterMedia.fromJson(data as Map<String, dynamic>);
  }

  /// Fetch multiple GIFs by IDs.
  ///
  /// Cached for 30 minutes — GIF metadata is immutable.
  Future<List<HeypsterMedia>> getByIds(List<String> ids) async {
    final json = await _get('/v1/gifs', {
      'ids': ids.join(','),
    }, ttl: const Duration(minutes: 30));
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => HeypsterMedia.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Autocomplete tag search.
  Future<List<String>> searchTags(String query) async {
    final json = await _get('/v1/gifs/search/tags', {'q': query});
    final data = json['data'] as List<dynamic>? ?? [];
    return data.map((item) {
      if (item is Map) return item['name'] as String? ?? '';
      return item.toString();
    }).toList();
  }

  /// Fetch trending search terms.
  Future<List<String>> trendingSearchTerms() async {
    final json = await _get('/v1/trending/searches', {});
    final data = json['data'] as List<dynamic>? ?? [];
    return data.map((item) => item.toString()).toList();
  }

  /// Fetch emoji GIFs.
  ///
  /// Cached for 10 minutes — curated list, rarely changes.
  Future<HeypsterPaginatedResponse<HeypsterMedia>> emoji({
    int limit = ApiConstants.defaultLimit,
    int offset = 0,
  }) async {
    final params = {'limit': limit.toString(), 'offset': offset.toString()};
    return _fetchPaginatedMedia(
      '/v1/emoji',
      params,
      ttl: const Duration(minutes: 10),
    );
  }

  // -- Internal helpers --

  Future<HeypsterPaginatedResponse<HeypsterMedia>> _fetchPaginatedMedia(
    String path,
    Map<String, String> params, {
    Duration ttl = const Duration(minutes: 5),
  }) async {
    final json = await _get(path, params, ttl: ttl);
    final data = json['data'] as List<dynamic>? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    final items = data
        .map((item) => HeypsterMedia.fromJson(item as Map<String, dynamic>))
        .toList();

    return HeypsterPaginatedResponse(
      data: items,
      totalCount: pagination['total_count'] as int? ?? 0,
      count: pagination['count'] as int? ?? items.length,
      offset: pagination['offset'] as int? ?? 0,
    );
  }

  /// GET with cache. Checks cache first, falls back to network.
  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> params, {
    Duration ttl = const Duration(minutes: 5),
  }) async {
    final cacheKey = _buildCacheKey(path, params);

    // Check cache
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) return cached;

    // Fetch from network
    final result = await _getFromNetwork(path, params);

    // Store in cache
    _cache.set(cacheKey, result, ttl: ttl);

    return result;
  }

  /// GET without cache — always hits the network.
  Future<Map<String, dynamic>> _getFromNetwork(
    String path,
    Map<String, String> params,
  ) async {
    return withRetry(() async {
      final uri = Uri.parse(
        '${ApiConstants.giphyBaseUrl}$path',
      ).replace(queryParameters: {...params, 'api_key': _apiKey});

      final http.Response response;
      try {
        response = await _client.get(uri).timeout(const Duration(seconds: 15));
      } on Exception catch (e) {
        throw HeypsterRequestError(cause: e);
      }

      if (response.statusCode != 200) {
        throw HeypsterRequestError(statusCode: response.statusCode);
      }

      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } on FormatException catch (e) {
        throw HeypsterDecodingError('Invalid JSON response', cause: e);
      }
    });
  }

  String _buildCacheKey(String path, Map<String, String> params) {
    final sorted = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final query = sorted.entries.map((e) => '${e.key}=${e.value}').join('&');
    return 'giphy:$path${query.isEmpty ? '' : '?$query'}';
  }
}
