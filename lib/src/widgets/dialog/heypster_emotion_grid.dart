import 'package:flutter/material.dart';

import '../../dto/heypster_emotion.dart';
import '../../l10n/generated/heypster_localizations.dart';

/// A grid of selectable emotion buttons.
///
/// Displays the 26 selectable emotions as labeled icon buttons.
/// Tapping one invokes [onEmotionSelected].
class HeypsterEmotionGrid extends StatelessWidget {
  /// Called when an emotion is selected.
  final void Function(HeypsterEmotion emotion) onEmotionSelected;

  /// Accent color for the emotion buttons.
  final Color? accentColor;

  const HeypsterEmotionGrid({
    super.key,
    required this.onEmotionSelected,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final emotions = HeypsterEmotion.selectableEmotions;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 110,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: emotions.length,
      itemBuilder: (context, index) {
        final emotion = emotions[index];
        return _EmotionButton(
          emotion: emotion,
          accentColor: accentColor,
          onTap: () => onEmotionSelected(emotion),
        );
      },
    );
  }
}

class _EmotionButton extends StatelessWidget {
  final HeypsterEmotion emotion;
  final Color? accentColor;
  final VoidCallback onTap;

  const _EmotionButton({
    required this.emotion,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = HeypsterLocalizations.of(context);
    final label = _emotionLabel(emotion, l10n);
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: theme.colorScheme.onSurface.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                emotion.assetPath,
                package: 'heypster_flutter_sdk',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, _, _) => Text(
                  emotion.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  static String _emotionEmoji(HeypsterEmotion emotion) {
    return switch (emotion) {
      HeypsterEmotion.laughing => '\u{1F602}',
      HeypsterEmotion.surprised => '\u{1F632}',
      HeypsterEmotion.happy => '\u{1F60A}',
      HeypsterEmotion.sad => '\u{1F622}',
      HeypsterEmotion.sleeping => '\u{1F634}',
      HeypsterEmotion.angry => '\u{1F621}',
      HeypsterEmotion.winking => '\u{1F609}',
      HeypsterEmotion.joy => '\u{1F929}',
      HeypsterEmotion.thinking => '\u{1F914}',
      HeypsterEmotion.disappointed => '\u{1F61E}',
      HeypsterEmotion.inLove => '\u{1F60D}',
      HeypsterEmotion.greedy => '\u{1F911}',
      HeypsterEmotion.afraid => '\u{1F628}',
      HeypsterEmotion.desperate => '\u{1F629}',
      HeypsterEmotion.cool => '\u{1F60E}',
      HeypsterEmotion.kissing => '\u{1F618}',
      HeypsterEmotion.hush => '\u{1F910}',
      HeypsterEmotion.mixed => '\u{1F615}',
      HeypsterEmotion.party => '\u{1F973}',
      HeypsterEmotion.confused => '\u{1F616}',
      HeypsterEmotion.swearing => '\u{1F92C}',
      HeypsterEmotion.clapping => '\u{1F44F}',
      HeypsterEmotion.hi => '\u{1F44B}',
      HeypsterEmotion.like => '\u{1F44D}',
      HeypsterEmotion.dislike => '\u{1F44E}',
      HeypsterEmotion.fingersCrossed => '\u{1F91E}',
      HeypsterEmotion.please => '\u{1F64F}',
    };
  }

  static String _emotionLabel(
    HeypsterEmotion emotion,
    HeypsterLocalizations? l10n,
  ) {
    if (l10n == null) return emotion.name;
    return switch (emotion) {
      HeypsterEmotion.laughing => l10n.emotionLaughing,
      HeypsterEmotion.surprised => l10n.emotionSurprised,
      HeypsterEmotion.happy => l10n.emotionHappy,
      HeypsterEmotion.sad => l10n.emotionSad,
      HeypsterEmotion.sleeping => l10n.emotionSleeping,
      HeypsterEmotion.angry => l10n.emotionAngry,
      HeypsterEmotion.winking => l10n.emotionWinking,
      HeypsterEmotion.joy => l10n.emotionJoy,
      HeypsterEmotion.thinking => l10n.emotionThinking,
      HeypsterEmotion.disappointed => l10n.emotionDisappointed,
      HeypsterEmotion.inLove => l10n.emotionInLove,
      HeypsterEmotion.greedy => l10n.emotionGreedy,
      HeypsterEmotion.afraid => l10n.emotionAfraid,
      HeypsterEmotion.desperate => l10n.emotionDesperate,
      HeypsterEmotion.cool => l10n.emotionCool,
      HeypsterEmotion.kissing => l10n.emotionKissing,
      HeypsterEmotion.hush => l10n.emotionHush,
      HeypsterEmotion.mixed => l10n.emotionMixed,
      HeypsterEmotion.party => l10n.emotionParty,
      HeypsterEmotion.confused => l10n.emotionConfused,
      HeypsterEmotion.swearing => l10n.emotionSwearing,
      HeypsterEmotion.clapping => l10n.emotionClapping,
      HeypsterEmotion.hi => l10n.emotionHi,
      HeypsterEmotion.like => l10n.emotionLike,
      HeypsterEmotion.dislike => l10n.emotionDislike,
      HeypsterEmotion.fingersCrossed => l10n.emotionFingersCrossed,
      HeypsterEmotion.please => l10n.emotionPlease,
    };
  }
}
