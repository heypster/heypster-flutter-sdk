import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'cache/heypster_media_cache.dart';
import 'dto/heypster_cache_policy.dart';
import 'dto/heypster_media.dart';
import 'dto/heypster_settings.dart';
import 'heypster_flutter_sdk_base.dart';
import 'heypster_media_selection_listener.dart';
import 'net/heypster_client.dart';
import 'widgets/dialog/heypster_dialog_content.dart';

/// Width threshold below which the picker uses a bottom sheet
/// instead of a centered dialog.
const _sheetWidthThreshold = 800.0;

/// Singleton providing pre-built templates for the heypster GIF
/// picker experience.
///
/// On narrow screens (< 800pt, typically phones), the picker is
/// presented as a draggable bottom sheet. On wider screens
/// (tablets, desktop, web), it appears as a centered modal dialog.
///
/// ```dart
/// HeypsterDialog.instance.addListener(myListener);
/// HeypsterDialog.instance.show(context: context);
/// ```
class HeypsterDialog {
  HeypsterDialog._();

  static final HeypsterDialog _instance = HeypsterDialog._();

  /// The singleton instance.
  static HeypsterDialog get instance => _instance;

  final List<HeypsterMediaSelectionListener> _listeners = [];
  HeypsterSettings _settings = const HeypsterSettings();
  BuildContext? _dialogContext;

  /// Configures the dialog with the given settings.
  void configure({HeypsterSettings? settings}) {
    if (settings != null) _settings = settings;
  }

  /// Shows the GIF picker.
  ///
  /// On phones (narrow screens, Android/iOS), presents as a
  /// draggable bottom sheet. On wider screens (tablets, desktop,
  /// web), presents as a centered modal dialog.
  void show({required BuildContext context}) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobileSheet =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) &&
        width < _sheetWidthThreshold;

    if (isMobileSheet) {
      _showAsBottomSheet(context);
    } else {
      _showAsDialog(context);
    }
  }

  /// Hides the currently showing picker.
  void hide() {
    final ctx = _dialogContext;
    if (ctx != null && ctx.mounted) {
      Navigator.of(ctx).pop();
    }
    _dialogContext = null;
  }

  /// Adds a listener for media selection and dismissal events.
  void addListener(HeypsterMediaSelectionListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  /// Removes a previously added listener.
  void removeListener(HeypsterMediaSelectionListener listener) {
    _listeners.remove(listener);
  }

  // -- Bottom sheet (phones) --

  void _showAsBottomSheet(BuildContext context) {
    final bgColor =
        _settings.theme.backgroundColor ??
        Theme.of(context).colorScheme.surface;
    final sheetController = DraggableScrollableController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        _dialogContext = sheetContext;
        return DraggableScrollableSheet(
          controller: sheetController,
          initialChildSize: _settings.initialSheetSize,
          minChildSize: _settings.minSheetSize,
          maxChildSize: _settings.maxSheetSize,
          expand: false,
          builder: (_, scrollController) {
            return HeypsterDialogContent(
              settings: _settings,
              scrollController: scrollController,
              sheetController: sheetController,
              onMediaSelect: _onMediaSelected,
              onDismiss: () => hide(),
              showHandleBar: true,
            );
          },
        );
      },
    ).then((_) {
      _dialogContext = null;
      _notifyDismissed();
    });
  }

  // -- Centered dialog (tablets, desktop, web) --

  void _showAsDialog(BuildContext context) {
    final bgColor =
        _settings.theme.backgroundColor ??
        Theme.of(context).colorScheme.surface;

    showDialog(
      context: context,
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        return Dialog(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: HeypsterDialogContent(
              settings: _settings,
              onMediaSelect: _onMediaSelected,
              onDismiss: () => hide(),
              showHandleBar: false,
            ),
          ),
        );
      },
    ).then((_) {
      _dialogContext = null;
      _notifyDismissed();
    });
  }

  // -- Callbacks --

  void _onMediaSelected(HeypsterMedia media) {
    for (final listener in List.of(_listeners)) {
      listener.onMediaSelect(media);
    }
    hide();
  }

  void _notifyDismissed() {
    if (HeypsterFlutterSDK.isConfigured) {
      final policy =
          _settings.cachePolicy ?? HeypsterFlutterSDK.config.cachePolicy;
      if (policy == HeypsterCachePolicy.clearOnDismiss) {
        HeypsterClient.instance.cache.clear();
        HeypsterMediaCache.instance.clear();
      }
    }

    for (final listener in List.of(_listeners)) {
      listener.onDismiss();
    }
  }
}
