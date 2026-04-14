/// Controls how the SDK manages its internal caches.
///
/// The SDK maintains two cache layers:
/// - **API response cache** (in-memory): JSON responses from the
///   heypster API, with a 5-minute TTL per entry.
/// - **Media file cache** (on-disk): GIF and MP4 files, stored for
///   up to 7 days with a max of 200 files.
enum HeypsterCachePolicy {
  /// Cache is cleared once when [HeypsterFlutterSDK.configure] is
  /// called.
  ///
  /// - **API responses:** Start empty (in-memory, natural).
  /// - **Media files:** Cleared from disk on configure.
  ///
  /// Good if users open the picker multiple times per session —
  /// cached media persists between picker open/close cycles but
  /// is cleared on next app launch.
  clearOnLaunch,

  /// Cache is cleared each time the picker dialog is dismissed.
  ///
  /// - **API responses:** Cleared from memory on dialog dismiss.
  /// - **Media files:** Cleared from disk on dialog dismiss.
  /// - **On app launch:** Both caches start empty (natural).
  ///
  /// This is the **default policy**. Minimizes storage footprint.
  clearOnDismiss,

  /// Cache is never automatically cleared.
  ///
  /// - **API responses:** Expire after their TTL (5 min default).
  /// - **Media files:** Expire after 7 days on disk, max 200 files.
  ///
  /// You may clear caches manually via
  /// `HeypsterClient.instance.cache.clear()` (API) and
  /// `HeypsterMediaCache.instance.clear()` (media).
  alwaysPersist,
}
