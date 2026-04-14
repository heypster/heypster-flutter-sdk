import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Disk-based cache for GIF and MP4 media files.
///
/// Wraps [flutter_cache_manager] with SDK-specific configuration.
/// Media files are cached for up to 7 days with a max of 200 files.
///
/// On web, this cache is a no-op — the browser's HTTP cache handles
/// media caching natively.
class HeypsterMediaCache {
  static final instance = HeypsterMediaCache._();

  BaseCacheManager? _manager;

  HeypsterMediaCache._();

  BaseCacheManager get _cacheManager {
    return _manager ??= CacheManager(
      Config(
        'heypsterMediaCache',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 200,
      ),
    );
  }

  /// Downloads and caches the file at [url], or returns the cached
  /// version if available.
  ///
  /// On web, returns `null` — callers should fall back to loading
  /// the URL directly via `Image.network` or
  /// `VideoPlayerController.networkUrl`.
  Future<File?> getFile(String url) async {
    if (kIsWeb) return null;
    try {
      return await _cacheManager.getSingleFile(url);
    } catch (_) {
      return null;
    }
  }

  /// Clears all cached media files from disk.
  Future<void> clear() async {
    if (kIsWeb) return;
    await _cacheManager.emptyCache();
  }
}
