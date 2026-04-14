/// Emotion categories for browsing GIFs by mood.
///
/// Each emotion has an integer ID used in the native heypster API.
enum HeypsterEmotion {
  /// Laughing emotion.
  laughing(2),

  /// Surprised emotion.
  surprised(8),

  /// Happy emotion.
  happy(9),

  /// Sad emotion.
  sad(6),

  /// Sleeping emotion.
  sleeping(10),

  /// Angry emotion.
  angry(1),

  /// Winking emotion.
  winking(11),

  /// Joy emotion.
  joy(3),

  /// Thinking emotion.
  thinking(12),

  /// Disappointed emotion.
  disappointed(7),

  /// In love emotion.
  inLove(4),

  /// Greedy/money emotion.
  greedy(5),

  /// Afraid/fear emotion.
  afraid(13),

  /// Desperate emotion.
  desperate(14),

  /// Cool emotion.
  cool(15),

  /// Kissing emotion.
  kissing(16),

  /// Hush/quiet emotion.
  hush(17),

  /// Mixed feelings emotion.
  mixed(26),

  /// Party emotion.
  party(21),

  /// Confused emotion.
  confused(23),

  /// Swearing emotion.
  swearing(24),

  /// Clapping emotion.
  clapping(18),

  /// Hi/greeting emotion.
  hi(19),

  /// Like/thumbs up emotion.
  like(25),

  /// Dislike/thumbs down emotion.
  dislike(20),

  /// Fingers crossed emotion.
  fingersCrossed(22),

  /// Please/prayer emotion.
  please(27);

  /// The API identifier for this emotion.
  final int id;

  const HeypsterEmotion(this.id);

  /// Path to the illustrated image for this emotion, bundled with the SDK.
  ///
  /// Use with [AssetImage] or [Image.asset] — pass
  /// `package: 'heypster_flutter_sdk'` so the asset is resolved from this
  /// package rather than the consumer app.
  String get assetPath => 'assets/emotions/$_assetBaseName.png';

  /// Emoji fallback for this emotion.
  ///
  /// Retained as a lightweight textual representation alongside [assetPath]
  /// for contexts where an image is unavailable or not desired.
  String get emoji => switch (this) {
    laughing => '\u{1F602}',
    surprised => '\u{1F632}',
    happy => '\u{1F60A}',
    sad => '\u{1F622}',
    sleeping => '\u{1F634}',
    angry => '\u{1F621}',
    winking => '\u{1F609}',
    joy => '\u{1F929}',
    thinking => '\u{1F914}',
    disappointed => '\u{1F61E}',
    inLove => '\u{1F60D}',
    greedy => '\u{1F911}',
    afraid => '\u{1F628}',
    desperate => '\u{1F629}',
    cool => '\u{1F60E}',
    kissing => '\u{1F618}',
    hush => '\u{1F910}',
    mixed => '\u{1F615}',
    party => '\u{1F973}',
    confused => '\u{1F616}',
    swearing => '\u{1F92C}',
    clapping => '\u{1F44F}',
    hi => '\u{1F44B}',
    like => '\u{1F44D}',
    dislike => '\u{1F44E}',
    fingersCrossed => '\u{1F91E}',
    please => '\u{1F64F}',
  };

  String get _assetBaseName {
    final buffer = StringBuffer();
    for (var i = 0; i < name.length; i++) {
      final char = name[i];
      final lower = char.toLowerCase();
      if (char != lower && i > 0) buffer.write('_');
      buffer.write(lower);
    }
    return buffer.toString();
  }

  /// The emotions shown in the picker UI.
  ///
  /// Excludes [swearing] from the selectable set.
  static const selectableEmotions = [
    laughing,
    surprised,
    happy,
    sad,
    sleeping,
    angry,
    winking,
    joy,
    thinking,
    disappointed,
    inLove,
    greedy,
    afraid,
    desperate,
    cool,
    kissing,
    hush,
    mixed,
    party,
    confused,
    clapping,
    hi,
    like,
    dislike,
    fingersCrossed,
    please,
  ];

  /// Returns the [HeypsterEmotion] for the given API [id].
  ///
  /// Returns `null` if no emotion matches the ID.
  static HeypsterEmotion? fromId(int id) {
    for (final e in values) {
      if (e.id == id) return e;
    }
    return null;
  }
}
