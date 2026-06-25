import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Router Commander AI'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @routers.
  ///
  /// In en, this message translates to:
  /// **'Routers'**
  String get routers;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Network command center'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A clean foundation for router profiles, diagnostics, security insights, and AI guidance.'**
  String get dashboardSubtitle;

  /// No description provided for @commandCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Router Commander AI'**
  String get commandCenterTitle;

  /// No description provided for @commandCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The Sprint 1 shell is ready with navigation, localization, responsive layout, and a production theme system.'**
  String get commandCenterSubtitle;

  /// No description provided for @routerStatus.
  ///
  /// In en, this message translates to:
  /// **'Router status'**
  String get routerStatus;

  /// No description provided for @noRouterConnected.
  ///
  /// In en, this message translates to:
  /// **'No router connected'**
  String get noRouterConnected;

  /// No description provided for @wifiHealth.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi health'**
  String get wifiHealth;

  /// No description provided for @awaitingNetworkScan.
  ///
  /// In en, this message translates to:
  /// **'Awaiting scan'**
  String get awaitingNetworkScan;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @baselineReady.
  ///
  /// In en, this message translates to:
  /// **'Baseline ready'**
  String get baselineReady;

  /// No description provided for @speedTest.
  ///
  /// In en, this message translates to:
  /// **'Speed test'**
  String get speedTest;

  /// No description provided for @notMeasured.
  ///
  /// In en, this message translates to:
  /// **'Not measured'**
  String get notMeasured;

  /// No description provided for @foundationReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation is ready'**
  String get foundationReadyTitle;

  /// No description provided for @foundationReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'The app now has a scalable feature-first shell. Router communication is intentionally excluded from Sprint 1.'**
  String get foundationReadyMessage;

  /// No description provided for @routersTitle.
  ///
  /// In en, this message translates to:
  /// **'Router profiles'**
  String get routersTitle;

  /// No description provided for @routersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved routers will be managed from this area once communication modules are introduced.'**
  String get routersSubtitle;

  /// No description provided for @routersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No router profiles'**
  String get routersEmptyTitle;

  /// No description provided for @routersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'This foundation keeps profile storage and connection workflows separate from the user interface.'**
  String get routersEmptyMessage;

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Network tools'**
  String get toolsTitle;

  /// No description provided for @toolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics are organized by feature so each tool can grow independently.'**
  String get toolsSubtitle;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get wifi;

  /// No description provided for @connectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected devices'**
  String get connectedDevices;

  /// No description provided for @dsl.
  ///
  /// In en, this message translates to:
  /// **'DSL'**
  String get dsl;

  /// No description provided for @toolReady.
  ///
  /// In en, this message translates to:
  /// **'Module ready'**
  String get toolReady;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI assistant'**
  String get aiAssistantTitle;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The assistant area is prepared for future guidance, explanations, and troubleshooting workflows.'**
  String get aiAssistantSubtitle;

  /// No description provided for @aiEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant workspace'**
  String get aiEmptyTitle;

  /// No description provided for @aiEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'The foundation reserves this space without adding AI or router communication behavior in Sprint 1.'**
  String get aiEmptyMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control app appearance and language instantly.'**
  String get settingsSubtitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
