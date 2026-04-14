/// The heypster Flutter SDK.
///
/// A pure Dart/Flutter SDK for integrating heypster's GIF platform
/// into Flutter apps. Works on all Flutter platforms: iOS, Android,
/// Web, macOS, Windows, and Linux.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:heypster_flutter_sdk/heypster_flutter_sdk.dart';
///
/// // 1. Configure the SDK (once, at app startup)
/// HeypsterFlutterSDK.configure(apiKey: 'YOUR_API_KEY');
/// ```
///
/// See the [README](https://gitlab.com/heypster/heypster-sdk)
/// for full documentation.
library;

// SDK configuration
export 'src/heypster_flutter_sdk_base.dart'
    show HeypsterFlutterSDK, HeypsterConfig;

// Data transfer objects
export 'src/dto/heypster_badge.dart';
export 'src/dto/heypster_cache_policy.dart';
export 'src/dto/heypster_content_request.dart';
export 'src/dto/heypster_content_type.dart';
export 'src/dto/heypster_emotion.dart';
export 'src/dto/heypster_error.dart';
export 'src/dto/heypster_gif_quality.dart';
export 'src/dto/heypster_image.dart';
export 'src/dto/heypster_images.dart';
export 'src/dto/heypster_language.dart';
export 'src/dto/heypster_media.dart';
export 'src/dto/heypster_media_type.dart';
export 'src/dto/heypster_rating.dart';
export 'src/dto/heypster_rendition.dart';
export 'src/dto/heypster_settings.dart';
export 'src/dto/heypster_tag.dart';
export 'src/dto/heypster_theme.dart';
export 'src/dto/misc.dart';

// Networking (public response types only)
export 'src/net/heypster_paginated_response.dart'
    show HeypsterPaginatedResponse;

// Widgets
export 'src/widgets/heypster_grid_view.dart';
export 'src/widgets/heypster_media_view.dart';
export 'src/widgets/heypster_media_view_controller.dart';

// Dialog
export 'src/heypster_dialog.dart';
export 'src/heypster_media_selection_listener.dart';

// Localization
export 'src/l10n/generated/heypster_localizations.dart';
