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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  /// **'Timeboxing'**
  String get appTitle;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Timeboxing'**
  String get welcome;

  /// No description provided for @deleteSelectedTasks.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected Tasks'**
  String get deleteSelectedTasks;

  /// No description provided for @deleteTasksConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} tasks?'**
  String deleteTasksConfirmation(Object count);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @tipsAndInsights.
  ///
  /// In en, this message translates to:
  /// **'Tips & Insights'**
  String get tipsAndInsights;

  /// No description provided for @dailyTip.
  ///
  /// In en, this message translates to:
  /// **'Daily Tip'**
  String get dailyTip;

  /// No description provided for @productivityInsights.
  ///
  /// In en, this message translates to:
  /// **'Productivity Insights'**
  String get productivityInsights;

  /// No description provided for @timeManagementTips.
  ///
  /// In en, this message translates to:
  /// **'Time Management Tips'**
  String get timeManagementTips;

  /// No description provided for @learningResources.
  ///
  /// In en, this message translates to:
  /// **'Learning Resources'**
  String get learningResources;

  /// No description provided for @tipOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Tip of the Day'**
  String get tipOfTheDay;

  /// No description provided for @viewAllTips.
  ///
  /// In en, this message translates to:
  /// **'View All Tips'**
  String get viewAllTips;

  /// No description provided for @noInsightsYet.
  ///
  /// In en, this message translates to:
  /// **'Complete more tasks to see insights!'**
  String get noInsightsYet;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going! You\'re doing great.'**
  String get keepGoing;

  /// No description provided for @tip1Title.
  ///
  /// In en, this message translates to:
  /// **'The Two-Minute Rule'**
  String get tip1Title;

  /// No description provided for @tip1Description.
  ///
  /// In en, this message translates to:
  /// **'If a task takes less than two minutes, do it immediately. This prevents small tasks from piling up.'**
  String get tip1Description;

  /// No description provided for @tip2Title.
  ///
  /// In en, this message translates to:
  /// **'Time Blocking'**
  String get tip2Title;

  /// No description provided for @tip2Description.
  ///
  /// In en, this message translates to:
  /// **'Dedicate specific time blocks to different tasks. This helps maintain focus and reduces context switching.'**
  String get tip2Description;

  /// No description provided for @tip3Title.
  ///
  /// In en, this message translates to:
  /// **'Eat the Frog'**
  String get tip3Title;

  /// No description provided for @tip3Description.
  ///
  /// In en, this message translates to:
  /// **'Start your day with the most challenging task. Once it\'s done, everything else feels easier.'**
  String get tip3Description;

  /// No description provided for @tip4Title.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro Technique'**
  String get tip4Title;

  /// No description provided for @tip4Description.
  ///
  /// In en, this message translates to:
  /// **'Work in 25-minute focused sessions followed by 5-minute breaks. This maintains high productivity.'**
  String get tip4Description;

  /// No description provided for @tip5Title.
  ///
  /// In en, this message translates to:
  /// **'Batch Similar Tasks'**
  String get tip5Title;

  /// No description provided for @tip5Description.
  ///
  /// In en, this message translates to:
  /// **'Group similar tasks together and complete them in one session to improve efficiency.'**
  String get tip5Description;

  /// No description provided for @tip6Title.
  ///
  /// In en, this message translates to:
  /// **'Set Clear Goals'**
  String get tip6Title;

  /// No description provided for @tip6Description.
  ///
  /// In en, this message translates to:
  /// **'Define specific, measurable goals for each task. Clarity leads to better execution.'**
  String get tip6Description;

  /// No description provided for @tip7Title.
  ///
  /// In en, this message translates to:
  /// **'Eliminate Distractions'**
  String get tip7Title;

  /// No description provided for @tip7Description.
  ///
  /// In en, this message translates to:
  /// **'Turn off notifications and create a focused work environment during task execution.'**
  String get tip7Description;

  /// No description provided for @tip8Title.
  ///
  /// In en, this message translates to:
  /// **'Review and Reflect'**
  String get tip8Title;

  /// No description provided for @tip8Description.
  ///
  /// In en, this message translates to:
  /// **'Spend 10 minutes at the end of each day reviewing what you accomplished and planning tomorrow.'**
  String get tip8Description;

  /// No description provided for @tip9Title.
  ///
  /// In en, this message translates to:
  /// **'The 80/20 Rule'**
  String get tip9Title;

  /// No description provided for @tip9Description.
  ///
  /// In en, this message translates to:
  /// **'Focus on the 20% of tasks that will generate 80% of your results. Prioritize wisely.'**
  String get tip9Description;

  /// No description provided for @tip10Title.
  ///
  /// In en, this message translates to:
  /// **'Take Regular Breaks'**
  String get tip10Title;

  /// No description provided for @tip10Description.
  ///
  /// In en, this message translates to:
  /// **'Short breaks improve focus and prevent burnout. Your brain needs rest to perform optimally.'**
  String get tip10Description;

  /// No description provided for @tip11Title.
  ///
  /// In en, this message translates to:
  /// **'Single-Tasking'**
  String get tip11Title;

  /// No description provided for @tip11Description.
  ///
  /// In en, this message translates to:
  /// **'Focus on one task at a time. Multitasking reduces quality and increases completion time.'**
  String get tip11Description;

  /// No description provided for @tip12Title.
  ///
  /// In en, this message translates to:
  /// **'Plan Tomorrow Today'**
  String get tip12Title;

  /// No description provided for @tip12Description.
  ///
  /// In en, this message translates to:
  /// **'Spend 5 minutes before bed planning tomorrow\'s tasks. You\'ll wake up with clarity and purpose.'**
  String get tip12Description;

  /// No description provided for @insight1.
  ///
  /// In en, this message translates to:
  /// **'You\'re most productive on {day}. Schedule important tasks on this day!'**
  String insight1(Object day);

  /// No description provided for @insight2.
  ///
  /// In en, this message translates to:
  /// **'Your average task completion rate is {rate}%. Keep up the good work!'**
  String insight2(Object rate);

  /// No description provided for @insight3.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed {count} tasks this week. That\'s impressive!'**
  String insight3(Object count);

  /// No description provided for @insight4.
  ///
  /// In en, this message translates to:
  /// **'Try breaking larger tasks into smaller chunks for better completion rates.'**
  String get insight4;

  /// No description provided for @insight5.
  ///
  /// In en, this message translates to:
  /// **'You work best in {duration}-minute sessions. Use this to your advantage!'**
  String insight5(Object duration);
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
