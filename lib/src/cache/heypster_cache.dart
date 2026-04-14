/// A lightweight in-memory LRU cache for HTTP responses.
///
/// Used internally by the SDK to avoid redundant network requests
/// within a session. The cache respects [HeypsterCachePolicy]:
///
/// - [HeypsterCachePolicy.clearOnLaunch]: Natural behavior — the
///   in-memory cache is empty on app start.
/// - [HeypsterCachePolicy.clearOnDismiss]: Cache is cleared when
///   the dialog dismisses.
/// - [HeypsterCachePolicy.alwaysPersist]: Cache survives dialog
///   open/close cycles within the app session.
class HeypsterCache {
  final int _maxEntries;
  final _entries = <String, _CacheEntry>{};

  /// Creates a cache with the given maximum number of entries.
  HeypsterCache({int maxEntries = 100}) : _maxEntries = maxEntries;

  /// Returns the cached value for [key], or `null` if not cached
  /// or expired.
  T? get<T>(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _entries.remove(key);
      return null;
    }
    // Move to end (most recently used)
    _entries.remove(key);
    _entries[key] = entry;
    final value = entry.value;
    return value is T ? value : null;
  }

  /// Stores [value] under [key] with an optional [ttl].
  ///
  /// Defaults to a 5-minute TTL.
  void set<T>(
    String key,
    T value, {
    Duration ttl = const Duration(minutes: 5),
  }) {
    if (_entries.length >= _maxEntries) {
      // Evict the least recently used entry (first in map)
      _entries.remove(_entries.keys.first);
    }
    _entries[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  /// Removes a specific entry.
  void remove(String key) => _entries.remove(key);

  /// Clears all cached entries.
  void clear() => _entries.clear();

  /// The number of entries currently cached.
  int get length => _entries.length;

  /// Whether the cache contains an entry for [key].
  bool containsKey(String key) {
    final entry = _entries[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _entries.remove(key);
      return false;
    }
    return true;
  }
}

class _CacheEntry {
  final Object? value;
  final DateTime expiresAt;

  _CacheEntry({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
