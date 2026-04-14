import 'dto/heypster_media.dart';

/// Handles events from the [HeypsterDialog].
///
/// Implement this abstract class and register it via
/// [HeypsterDialog.addListener] to receive media selection and
/// dismissal callbacks.
///
/// ```dart
/// class MyScreen extends StatefulWidget
///     implements HeypsterMediaSelectionListener {
///   @override
///   void onMediaSelect(HeypsterMedia media) {
///     // Handle selected media
///   }
///
///   @override
///   void onDismiss() {
///     // Handle dialog dismissal
///   }
/// }
/// ```
abstract class HeypsterMediaSelectionListener {
  /// Called when a media item is selected in the dialog.
  void onMediaSelect(HeypsterMedia media);

  /// Called when the dialog is dismissed.
  void onDismiss();
}
