import 'package:http/http.dart' as http;

import '../cache/heypster_cache.dart';
import '../heypster_flutter_sdk_base.dart';
import 'giphy_api_service.dart';
import 'native_api_service.dart';

/// Internal HTTP client for the heypster SDK.
///
/// Provides access to both the GIPHY-compatible API and the native
/// heypster SDK API. Initialized automatically when
/// [HeypsterFlutterSDK.configure] is called.
///
/// Not exported to consumers — use the public API instead.
class HeypsterClient {
  static HeypsterClient? _instance;

  /// The GIPHY-compatible API service.
  final GiphyApiService giphyApi;

  /// The native heypster SDK API service.
  final NativeApiService nativeApi;

  /// The underlying HTTP client (exposed for testing/disposal).
  final http.Client httpClient;

  /// In-memory response cache.
  final HeypsterCache cache;

  HeypsterClient._({
    required this.giphyApi,
    required this.nativeApi,
    required this.httpClient,
    required this.cache,
  });

  /// Returns the singleton instance, creating it if needed.
  ///
  /// Uses the API key from [HeypsterFlutterSDK.config].
  static HeypsterClient get instance {
    if (_instance != null) return _instance!;
    final config = HeypsterFlutterSDK.config;
    return _instance = _create(config.apiKey);
  }

  /// Creates a new client with the given API key and HTTP client.
  ///
  /// Primarily for testing — allows injecting a mock HTTP client.
  static HeypsterClient create({
    required String apiKey,
    http.Client? httpClient,
  }) {
    return _create(apiKey, httpClient: httpClient);
  }

  /// Resets the singleton. Intended for testing only.
  static void reset() {
    _instance?.httpClient.close();
    _instance = null;
  }

  static HeypsterClient _create(String apiKey, {http.Client? httpClient}) {
    final client = httpClient ?? http.Client();
    final cache = HeypsterCache();
    return HeypsterClient._(
      giphyApi: GiphyApiService(client: client, apiKey: apiKey, cache: cache),
      nativeApi: NativeApiService(client: client, apiKey: apiKey, cache: cache),
      httpClient: client,
      cache: cache,
    );
  }
}
