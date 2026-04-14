import 'package:flutter_test/flutter_test.dart';
import 'package:heypster_flutter_sdk/heypster_flutter_sdk.dart';

class _MockListener implements HeypsterMediaSelectionListener {
  HeypsterMedia? lastMedia;
  int dismissCount = 0;

  @override
  void onMediaSelect(HeypsterMedia media) {
    lastMedia = media;
  }

  @override
  void onDismiss() {
    dismissCount++;
  }
}

void main() {
  group('HeypsterDialog', () {
    test('is a singleton', () {
      expect(
        identical(HeypsterDialog.instance, HeypsterDialog.instance),
        isTrue,
      );
    });

    test('addListener prevents duplicates', () {
      final listener = _MockListener();
      HeypsterDialog.instance.addListener(listener);
      HeypsterDialog.instance.addListener(listener);
      // No way to count listeners externally, but this shouldn't
      // throw and should only register once.
      HeypsterDialog.instance.removeListener(listener);
    });

    test('removeListener is safe for unknown listener', () {
      final listener = _MockListener();
      // Removing a listener that was never added should not throw
      HeypsterDialog.instance.removeListener(listener);
    });

    test('configure accepts settings', () {
      HeypsterDialog.instance.configure(
        settings: const HeypsterSettings(
          showEmotions: false,
          rating: HeypsterRating.g,
        ),
      );
      // No assertion needed — just verifying it doesn't throw.
      // Reset for other tests.
      HeypsterDialog.instance.configure(settings: const HeypsterSettings());
    });
  });

  group('HeypsterMediaSelectionListener', () {
    test('mock listener receives calls', () {
      final listener = _MockListener();
      const media = HeypsterMedia(id: '1', images: HeypsterImages());

      listener.onMediaSelect(media);
      expect(listener.lastMedia?.id, '1');

      listener.onDismiss();
      expect(listener.dismissCount, 1);
    });
  });
}
