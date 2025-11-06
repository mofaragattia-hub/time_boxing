// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Timeboxing';

  @override
  String get hello => 'Hello!';

  @override
  String get welcome => 'Welcome to Timeboxing';

  @override
  String get deleteSelectedTasks => 'Delete Selected Tasks';

  @override
  String deleteTasksConfirmation(Object count) {
    return 'Are you sure you want to delete $count tasks?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';
}
