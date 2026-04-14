import 'cache/heypster_media_cache.dart';
import 'dto/heypster_cache_policy.dart';
import 'dto/heypster_error.dart';
import 'dto/heypster_gif_quality.dart';
import 'dto/heypster_language.dart';
import 'net/heypster_client.dart';

/// Configuration state for the heypster SDK.
class HeypsterConfig {
  /// The API key for authenticating requests.
  final String apiKey;

  /// The cache policy.
  final HeypsterCachePolicy cachePolicy;

  /// The preferred GIF quality.
  final HeypsterGifQuality gifQuality;

  /// The language for tag search.
  final HeypsterLanguage language;

  const HeypsterConfig({
    required this.apiKey,
    required this.cachePolicy,
    required this.gifQuality,
    required this.language,
  });
}

/// Entry point for configuring the heypster Flutter SDK.
///
/// You must call [configure] before using any other SDK feature.
///
/// ```dart
/// HeypsterFlutterSDK.configure(apiKey: 'YOUR_API_KEY');
/// ```
class HeypsterFlutterSDK {
  static HeypsterConfig? _config;

  HeypsterFlutterSDK._();

  /// Configures the SDK with the given settings.
  ///
  /// [apiKey] is required and must not be empty.
  ///
  /// [cachePolicy] controls when cached data is cleared:
  /// - [HeypsterCachePolicy.clearOnDismiss] **(default)**: API
  ///   response cache and media file cache are both cleared each
  ///   time the dialog is dismissed.
  /// - [HeypsterCachePolicy.clearOnLaunch]: Media file cache is
  ///   cleared on this call. API response cache starts empty
  ///   naturally (in-memory).
  /// - [HeypsterCachePolicy.alwaysPersist]: Caches are never
  ///   auto-cleared. API responses expire after their TTL (5 min).
  ///   Media files expire after 7 days on disk.
  static void configure({
    required String apiKey,
    HeypsterCachePolicy cachePolicy = HeypsterCachePolicy.clearOnDismiss,
    HeypsterGifQuality gifQuality = HeypsterGifQuality.mini,
    HeypsterLanguage language = HeypsterLanguage.english,
  }) {
    if (apiKey.isEmpty) {
      throw ArgumentError.value(apiKey, 'apiKey', 'Must not be empty');
    }
    HeypsterClient.reset();
    _config = HeypsterConfig(
      apiKey: apiKey,
      cachePolicy: cachePolicy,
      gifQuality: gifQuality,
      language: language,
    );

    // Clear persisted media cache from previous session
    if (cachePolicy == HeypsterCachePolicy.clearOnLaunch) {
      HeypsterMediaCache.instance.clear();
    }
  }

  /// Returns the current configuration.
  ///
  /// Throws [HeypsterNotConfiguredError] if [configure] has not
  /// been called.
  static HeypsterConfig get config {
    final c = _config;
    if (c == null) throw HeypsterNotConfiguredError();
    return c;
  }

  /// Whether the SDK has been configured.
  static bool get isConfigured => _config != null;

  /// Disposes the SDK, releasing all resources.
  ///
  /// Closes the HTTP client, clears in-memory and disk caches,
  /// and resets the configuration. After calling this, you must
  /// call [configure] again before using the SDK.
  ///
  /// Call this when the SDK is no longer needed (e.g., on app
  /// teardown or when switching API keys).
  static void dispose() {
    HeypsterClient.reset();
    HeypsterMediaCache.instance.clear();
    _config = null;
  }

  /// Resets the SDK configuration. Intended for testing only.
  static void reset() => _config = null;
}
