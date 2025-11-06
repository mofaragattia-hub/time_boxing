// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تيمبوكسينج';

  @override
  String get hello => 'أهلاً!';

  @override
  String get welcome => 'مرحباً بك في تيمبوكسينج';

  @override
  String get deleteSelectedTasks => 'حذف المهام المحددة';

  @override
  String deleteTasksConfirmation(Object count) {
    return 'هل أنت متأكد من حذف $count مهام؟';
  }

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';
}
