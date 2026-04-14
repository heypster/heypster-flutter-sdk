import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'heypster_localizations_da.dart';
import 'heypster_localizations_de.dart';
import 'heypster_localizations_en.dart';
import 'heypster_localizations_es.dart';
import 'heypster_localizations_fi.dart';
import 'heypster_localizations_fr.dart';
import 'heypster_localizations_it.dart';
import 'heypster_localizations_nl.dart';
import 'heypster_localizations_no.dart';
import 'heypster_localizations_pt.dart';
import 'heypster_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of HeypsterLocalizations
/// returned by `HeypsterLocalizations.of(context)`.
///
/// Applications need to include `HeypsterLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/heypster_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: HeypsterLocalizations.localizationsDelegates,
///   supportedLocales: HeypsterLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the HeypsterLocalizations.supportedLocales
/// property.
abstract class HeypsterLocalizations {
  HeypsterLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static HeypsterLocalizations? of(BuildContext context) {
    return Localizations.of<HeypsterLocalizations>(
      context,
      HeypsterLocalizations,
    );
  }

  static const LocalizationsDelegate<HeypsterLocalizations> delegate =
      _HeypsterLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('no'),
    Locale('pt'),
    Locale('sv'),
  ];

  /// No description provided for @emotions.
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get emotions;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @browseByEmotion.
  ///
  /// In en, this message translates to:
  /// **'Browse by emotion'**
  String get browseByEmotion;

  /// No description provided for @searchGifs.
  ///
  /// In en, this message translates to:
  /// **'Search GIFs...'**
  String get searchGifs;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Try again.'**
  String get searchFailed;

  /// No description provided for @failedToLoadGifs.
  ///
  /// In en, this message translates to:
  /// **'Failed to load GIFs'**
  String get failedToLoadGifs;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noGifsFound.
  ///
  /// In en, this message translates to:
  /// **'No GIFs found'**
  String get noGifsFound;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @emotionLaughing.
  ///
  /// In en, this message translates to:
  /// **'Laughing'**
  String get emotionLaughing;

  /// No description provided for @emotionSurprised.
  ///
  /// In en, this message translates to:
  /// **'Surprised'**
  String get emotionSurprised;

  /// No description provided for @emotionHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get emotionHappy;

  /// No description provided for @emotionSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get emotionSad;

  /// No description provided for @emotionSleeping.
  ///
  /// In en, this message translates to:
  /// **'Sleeping'**
  String get emotionSleeping;

  /// No description provided for @emotionAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get emotionAngry;

  /// No description provided for @emotionWinking.
  ///
  /// In en, this message translates to:
  /// **'Winking'**
  String get emotionWinking;

  /// No description provided for @emotionJoy.
  ///
  /// In en, this message translates to:
  /// **'Joy'**
  String get emotionJoy;

  /// No description provided for @emotionThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get emotionThinking;

  /// No description provided for @emotionDisappointed.
  ///
  /// In en, this message translates to:
  /// **'Disappointed'**
  String get emotionDisappointed;

  /// No description provided for @emotionInLove.
  ///
  /// In en, this message translates to:
  /// **'In Love'**
  String get emotionInLove;

  /// No description provided for @emotionGreedy.
  ///
  /// In en, this message translates to:
  /// **'Greedy'**
  String get emotionGreedy;

  /// No description provided for @emotionAfraid.
  ///
  /// In en, this message translates to:
  /// **'Afraid'**
  String get emotionAfraid;

  /// No description provided for @emotionDesperate.
  ///
  /// In en, this message translates to:
  /// **'Desperate'**
  String get emotionDesperate;

  /// No description provided for @emotionCool.
  ///
  /// In en, this message translates to:
  /// **'Cool'**
  String get emotionCool;

  /// No description provided for @emotionKissing.
  ///
  /// In en, this message translates to:
  /// **'Kissing'**
  String get emotionKissing;

  /// No description provided for @emotionHush.
  ///
  /// In en, this message translates to:
  /// **'Hush'**
  String get emotionHush;

  /// No description provided for @emotionMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get emotionMixed;

  /// No description provided for @emotionParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get emotionParty;

  /// No description provided for @emotionConfused.
  ///
  /// In en, this message translates to:
  /// **'Confused'**
  String get emotionConfused;

  /// No description provided for @emotionSwearing.
  ///
  /// In en, this message translates to:
  /// **'Swearing'**
  String get emotionSwearing;

  /// No description provided for @emotionClapping.
  ///
  /// In en, this message translates to:
  /// **'Clapping'**
  String get emotionClapping;

  /// No description provided for @emotionHi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get emotionHi;

  /// No description provided for @emotionLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get emotionLike;

  /// No description provided for @emotionDislike.
  ///
  /// In en, this message translates to:
  /// **'Dislike'**
  String get emotionDislike;

  /// No description provided for @emotionFingersCrossed.
  ///
  /// In en, this message translates to:
  /// **'Fingers Crossed'**
  String get emotionFingersCrossed;

  /// No description provided for @emotionPlease.
  ///
  /// In en, this message translates to:
  /// **'Please'**
  String get emotionPlease;
}

class _HeypsterLocalizationsDelegate
    extends LocalizationsDelegate<HeypsterLocalizations> {
  const _HeypsterLocalizationsDelegate();

  @override
  Future<HeypsterLocalizations> load(Locale locale) {
    return SynchronousFuture<HeypsterLocalizations>(
      lookupHeypsterLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'da',
    'de',
    'en',
    'es',
    'fi',
    'fr',
    'it',
    'nl',
    'no',
    'pt',
    'sv',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_HeypsterLocalizationsDelegate old) => false;
}

HeypsterLocalizations lookupHeypsterLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return HeypsterLocalizationsDa();
    case 'de':
      return HeypsterLocalizationsDe();
    case 'en':
      return HeypsterLocalizationsEn();
    case 'es':
      return HeypsterLocalizationsEs();
    case 'fi':
      return HeypsterLocalizationsFi();
    case 'fr':
      return HeypsterLocalizationsFr();
    case 'it':
      return HeypsterLocalizationsIt();
    case 'nl':
      return HeypsterLocalizationsNl();
    case 'no':
      return HeypsterLocalizationsNo();
    case 'pt':
      return HeypsterLocalizationsPt();
    case 'sv':
      return HeypsterLocalizationsSv();
  }

  throw FlutterError(
    'HeypsterLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
