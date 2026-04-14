# Migrating from Giphy Flutter SDK to heypster

This guide helps you migrate from `giphy_flutter_sdk` to
`heypster_flutter_sdk`. The heypster SDK was designed to feel
familiar — most changes are simple renames.

## 1. Update your import

```dart
// Before
import 'package:giphy_flutter_sdk/giphy_flutter_sdk.dart';

// After
import 'package:heypster_flutter_sdk/heypster_flutter_sdk.dart';
```

## 2. SDK Configuration

```dart
// Before (Giphy)
GiphyFlutterSDK.configure(
  apiKey: 'YOUR_GIPHY_KEY',
  verificationMode: false,
  videoCacheMaxBytes: 100 * 1024 * 1024,
);

// After (heypster)
HeypsterFlutterSDK.configure(
  apiKey: 'YOUR_HEYPSTER_KEY',
  cachePolicy: HeypsterCachePolicy.clearOnDismiss,  // optional
  gifQuality: HeypsterGifQuality.mini,               // optional
  language: HeypsterLanguage.english,                 // optional
);
```

| Giphy Parameter | heypster Equivalent | Notes |
|-----------------|---------------------|-------|
| `apiKey` | `apiKey` | Replace your Giphy key with a heypster key |
| `verificationMode` | Removed | Not applicable |
| `videoCacheMaxBytes` | `cachePolicy` | heypster manages cache automatically |
| — | `gifQuality` | **New:** choose between mini (240p) and full (480p) |
| — | `language` | **New:** set language for tag search (11 languages) |

## 3. Register Localizations

heypster's UI is localized in 11 languages. Add the delegate to
your `MaterialApp`:

```dart
MaterialApp(
  localizationsDelegates: [
    ...GlobalMaterialLocalizations.delegates,
    HeypsterLocalizations.delegate,   // <-- add this
  ],
  supportedLocales: [
    ...HeypsterLocalizations.supportedLocales,
  ],
)
```

## 4. Dialog (GIF Picker)

The dialog uses the same singleton + listener pattern as Giphy.
One difference: `show()` requires a `BuildContext` because the
SDK is pure Flutter (no platform channels).

```dart
// Before (Giphy)
class _MyState extends State<MyScreen>
    implements GiphyMediaSelectionListener {

  @override
  void initState() {
    super.initState();
    GiphyDialog.instance.addListener(this);
  }

  @override
  void onMediaSelect(GiphyMedia media) {
    // Handle selection
  }

  @override
  void onDismiss() {}

  void _openPicker() {
    GiphyDialog.instance.show();  // no parameters
  }
}

// After (heypster)
class _MyState extends State<MyScreen>
    implements HeypsterMediaSelectionListener {

  @override
  void initState() {
    super.initState();
    HeypsterDialog.instance.addListener(this);
  }

  @override
  void onMediaSelect(HeypsterMedia media) {
    // Handle selection
  }

  @override
  void onDismiss() {}

  void _openPicker() {
    HeypsterDialog.instance.show(context: context);  // pass context
  }
}
```

| Change | What to do |
|--------|------------|
| `GiphyMediaSelectionListener` | Rename to `HeypsterMediaSelectionListener` |
| `GiphyDialog` | Rename to `HeypsterDialog` |
| `GiphyMedia` | Rename to `HeypsterMedia` |
| `.show()` | Change to `.show(context: context)` |

## 5. Media View (Display a GIF)

Nearly identical API. Remove `showCheckeredBackground` (sticker
feature, not available in heypster).

```dart
// Before (Giphy)
GiphyMediaView(
  media: selectedGif,
  autoPlay: true,
  renditionType: GiphyRendition.fixedWidth,
  resizeMode: GiphyResizeMode.cover,
  showCheckeredBackground: true,  // remove this
  onError: (err) => print(err),
)

// After (heypster)
HeypsterMediaView(
  media: selectedGif,
  autoPlay: true,
  renditionType: HeypsterRendition.fixedWidth,
  resizeMode: HeypsterResizeMode.cover,
  onError: (err) => print(err),
)
```

| Giphy Property | heypster Equivalent | Notes |
|----------------|---------------------|-------|
| `media` | `media` | Use `HeypsterMedia` instead of `GiphyMedia` |
| `mediaId` | `mediaId` | Same |
| `autoPlay` | `autoPlay` | Same (default: `true`) |
| `renditionType` | `renditionType` | Same values, different enum name |
| `resizeMode` | `resizeMode` | Same values, different enum name |
| `controller` | `controller` | Same API (`pause()` / `resume()`) |
| `onError` | `onError` | Same signature |
| `showCheckeredBackground` | Removed | Not applicable |

**Performance note:** heypster prefers MP4 video playback over
animated GIFs for better performance and lower bandwidth. This
is handled automatically — no code change needed.

## 6. Grid View (Embeddable Grid)

Same concept, fewer parameters (sticker/clip-specific properties
removed).

```dart
// Before (Giphy)
GiphyGridView(
  content: GiphyContentRequest.trendingGifs(),
  cellPadding: 8,
  renditionType: GiphyRendition.fixedWidth,
  clipsPreviewRenditionType: GiphyClipsRendition.fixedWidth,  // remove
  disableEmojiVariations: false,  // remove
  fixedSizeCells: false,          // remove
  showCheckeredBackground: false, // remove
  theme: GiphyTheme.automaticTheme,
  onMediaSelect: (media) => print(media.id),
)

// After (heypster)
HeypsterGridView(
  content: HeypsterContentRequest.trendingGifs(),
  cellPadding: 8,
  renditionType: HeypsterRendition.fixedWidth,
  theme: HeypsterTheme.automaticTheme,
  onMediaSelect: (media) => print(media.id),
)
```

| Removed Property | Reason |
|------------------|--------|
| `clipsPreviewRenditionType` | Clips not available |
| `disableEmojiVariations` | Emoji variations not applicable |
| `fixedSizeCells` | Sticker-specific feature |
| `showCheckeredBackground` | Sticker-specific feature |

## 7. Content Requests

```dart
// These map directly:
GiphyContentRequest.search(query: 'cats')  →  HeypsterContentRequest.search(searchQuery: 'cats')
GiphyContentRequest.trending()             →  HeypsterContentRequest.trending()
GiphyContentRequest.trendingGifs()         →  HeypsterContentRequest.trendingGifs()
GiphyContentRequest.emoji()                →  HeypsterContentRequest.emoji()

// These are removed (no heypster equivalent):
GiphyContentRequest.trendingStickers()     →  ❌ Not available
GiphyContentRequest.trendingText()         →  ❌ Not available
GiphyContentRequest.recents()              →  ❌ Not available
GiphyContentRequest.animate()              →  ❌ Not available

// These are new (heypster-specific):
HeypsterContentRequest.gifsOfTheDay()       // curated daily GIFs
HeypsterContentRequest.byEmotion(emotion)   // browse by emotion
HeypsterContentRequest.byTag(tag)           // browse by tag
HeypsterContentRequest.byBadge(badge)       // browse by badge
```

## 8. Enum Mapping

| Giphy | heypster | Values |
|-------|----------|--------|
| `GiphyRendition` | `HeypsterRendition` | Same values (original, fixedWidth, fixedHeight, etc.) |
| `GiphyRating` | `HeypsterRating` | g, pg, pg13, r (heypster omits unrated, y, nsfw) |
| `GiphyDirection` | `HeypsterDirection` | horizontal, vertical |
| `GiphyResizeMode` | `HeypsterResizeMode` | center, contain, cover, stretch |
| `GiphyContentType` | `HeypsterContentType` | gif, emoji (heypster omits recents, sticker, text, clips) |
| `GiphyMediaType` | `HeypsterMediaType` | gif, emoji (heypster omits sticker, text, video) |
| `GiphyThemePreset` | `HeypsterThemePreset` | automatic, dark, light |

## 9. Quick Migration Checklist

- [ ] Replace `giphy_flutter_sdk` dependency with `heypster_flutter_sdk`
- [ ] Update import statement
- [ ] `GiphyFlutterSDK.configure()` → `HeypsterFlutterSDK.configure()`
- [ ] Register `HeypsterLocalizations.delegate` in `MaterialApp`
- [ ] Rename all `Giphy*` classes to `Heypster*`
- [ ] Add `context:` parameter to `HeypsterDialog.instance.show()`
- [ ] Remove `showCheckeredBackground` from `MediaView` and `GridView`
- [ ] Remove clip/sticker properties from `GridView`
- [ ] Update `ContentRequest` factory constructors
- [ ] Remove platform-specific code (no more `MethodChannel` handling)
- [ ] Test on all target platforms (Web is now supported!)

## 10. Platform Support

| Platform | Giphy | heypster |
|----------|-------|----------|
| iOS | Yes | Yes |
| Android | Yes | Yes |
| Web | No | **Yes** |
| macOS | No | **Yes** |
| Windows | No | **Yes** |
| Linux | No | **Yes** |

## Need Help?

Contact us at contact@heypster.com
