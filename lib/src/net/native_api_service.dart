import 'dart:convert';

import 'package:http/http.dart' as http;

import '../cache/heypster_cache.dart';
import '../dto/heypster_error.dart';
import '../dto/heypster_native_gif.dart';
import '../dto/heypster_tag.dart';
import 'api_constants.dart';
import 'heypster_paginated_response.dart';
import 'retry.dart';

/// Service for the native heypster SDK API.
///
/// All endpoints use header authentication (`HEYPSTER-API-KEY`).
/// Responses are cached in-memory via [HeypsterCache] — identical
/// requests within the TTL window are served from cache.
class NativeApiService {
  final http.Client _client;
  final String _apiKey;
  final HeypsterCache _cache;

  NativeApiService({
    required http.Client client,
    required String apiKey,
    required HeypsterCache cache,
  }) : _client = client,
       _apiKey = apiKey,
       _cache = cache;

  /// Fetch GIFs of the day (paginated).
  Future<HeypsterNativePaginatedResponse<HeypsterNativeGif>> fetchGifsOfTheDay({
    int page = 1,
  }) {
    return _fetchPaginatedGifs('/gifs', page);
  }

  /// Fetch GIFs for a specific tag (paginated).
  Future<HeypsterNativePaginatedResponse<HeypsterNativeGif>> fetchGifsByTag(
    int tagId, {
    int page = 1,
  }) {
    return _fetchPaginatedGifs('/gifs-tags/$tagId', page);
  }

  /// Fetch GIFs for a specific emotion (paginated).
  Future<HeypsterNativePaginatedResponse<HeypsterNativeGif>> fetchGifsByEmotion(
    int emotionId, {
    int page = 1,
  }) {
    return _fetchPaginatedGifs('/gifs-emotions/$emotionId', page);
  }

  /// Fetch GIFs for a specific badge (paginated).
  Future<HeypsterNativePaginatedResponse<HeypsterNativeGif>> fetchGifsByBadge(
    int badgeId, {
    int page = 1,
  }) {
    return _fetchPaginatedGifs('/gifs-badges/$badgeId', page);
  }

  /// Search tags by text input and language.
  ///
  /// Returns a list of matching tags. The native API returns a bare
  /// array (not wrapped in `{data: [...]}`).
  Future<List<HeypsterTag>> searchTags(
    String input,
    String languageCode,
  ) async {
    final cleanInput = Uri.encodeComponent(input.toLowerCase());
    final path = '/tags/$cleanInput/$languageCode';
    final cacheKey = 'native:$path';

    // Check cache
    final cached = _cache.get<List<HeypsterTag>>(cacheKey);
    if (cached != null) return cached;

    final json = await _getRawFromNetwork(path);

    if (json is List) {
      final tags = json
          .map((item) => HeypsterTag.fromJson(item as Map<String, dynamic>))
          .toList();
      _cache.set(cacheKey, tags);
      return tags;
    }

    return [];
  }

  // -- Internal helpers --

  Future<HeypsterNativePaginatedResponse<HeypsterNativeGif>>
  _fetchPaginatedGifs(String path, int page) async {
    final params = {'page': page.toString()};
    final json = await _get(path, params);

    final data = json['data'] as List<dynamic>? ?? [];
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};

    final gifs = data
        .map((item) => HeypsterNativeGif.fromJson(item as Map<String, dynamic>))
        .toList();

    return HeypsterNativePaginatedResponse(
      data: gifs,
      pagination: HeypsterNativePagination.fromJson(paginationJson),
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
    final uri = Uri.parse(
      '${ApiConstants.nativeBaseUrl}$path',
    ).replace(queryParameters: params);
    final response = await _request(uri);

    Map<String, dynamic> result;
    try {
      result = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw HeypsterDecodingError('Invalid JSON response', cause: e);
    }

    // Store in cache
    _cache.set(cacheKey, result, ttl: ttl);

    return result;
  }

  /// GET that returns raw decoded JSON (may be a List or Map).
  /// Always hits network — caching handled by caller.
  Future<dynamic> _getRawFromNetwork(String path) async {
    final uri = Uri.parse('${ApiConstants.nativeBaseUrl}$path');
    final response = await _request(uri);

    try {
      return jsonDecode(response.body);
    } on FormatException catch (e) {
      throw HeypsterDecodingError('Invalid JSON response', cause: e);
    }
  }

  Future<http.Response> _request(Uri uri) async {
    return withRetry(() async {
      final http.Response response;
      try {
        response = await _client
            .get(uri, headers: {'HEYPSTER-API-KEY': _apiKey})
            .timeout(const Duration(seconds: 15));
      } on Exception catch (e) {
        throw HeypsterRequestError(cause: e);
      }

      if (response.statusCode != 200) {
        throw HeypsterRequestError(statusCode: response.statusCode);
      }

      return response;
    });
  }

  String _buildCacheKey(String path, Map<String, String> params) {
    final sorted = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final query = sorted.entries.map((e) => '${e.key}=${e.value}').join('&');
    return 'native:$path${query.isEmpty ? '' : '?$query'}';
  }
}
