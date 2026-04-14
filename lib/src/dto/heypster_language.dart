/// Languages supported by the heypster API for tag search.
enum HeypsterLanguage {
  /// English (default).
  english('en'),

  /// French.
  french('fr'),

  /// Danish.
  danish('da'),

  /// Dutch.
  dutch('nl'),

  /// German.
  german('de'),

  /// Swedish.
  swedish('sv'),

  /// Spanish.
  spanish('es'),

  /// Italian.
  italian('it'),

  /// Portuguese.
  portuguese('pt'),

  /// Norwegian.
  norwegian('no'),

  /// Finnish.
  finnish('fi');

  /// The ISO 639-1 language code.
  final String code;

  const HeypsterLanguage(this.code);

  /// Returns the [HeypsterLanguage] for the given ISO 639-1 [code].
  ///
  /// Returns `null` if the code is not recognized.
  static HeypsterLanguage? fromCode(String code) {
    for (final lang in values) {
      if (lang.code == code) return lang;
    }
    return null;
  }
}
