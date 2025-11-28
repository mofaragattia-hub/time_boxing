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

  @override
  String get tipsAndInsights => 'نصائح وإرشادات';

  @override
  String get dailyTip => 'نصيحة اليوم';

  @override
  String get productivityInsights => 'رؤى الإنتاجية';

  @override
  String get timeManagementTips => 'نصائح إدارة الوقت';

  @override
  String get learningResources => 'موارد التعلم';

  @override
  String get tipOfTheDay => 'نصيحة اليوم';

  @override
  String get viewAllTips => 'عرض جميع النصائح';

  @override
  String get noInsightsYet => 'أكمل المزيد من المهام لرؤية الإرشادات!';

  @override
  String get keepGoing => 'استمر! أنت تقوم بعمل رائع.';

  @override
  String get tip1Title => 'قاعدة الدقيقتين';

  @override
  String get tip1Description =>
      'إذا كانت المهمة تستغرق أقل من دقيقتين، قم بها فوراً. هذا يمنع تراكم المهام الصغيرة.';

  @override
  String get tip2Title => 'تقسيم الوقت';

  @override
  String get tip2Description =>
      'خصص فترات زمنية محددة لمهام مختلفة. هذا يساعد في الحفاظ على التركيز وتقليل التشتت.';

  @override
  String get tip3Title => 'ابدأ بالأصعب';

  @override
  String get tip3Description =>
      'ابدأ يومك بالمهمة الأكثر تحدياً. بمجرد إنجازها، سيبدو كل شيء آخر أسهل.';

  @override
  String get tip4Title => 'تقنية بومودورو';

  @override
  String get tip4Description =>
      'اعمل في جلسات مركزة مدتها 25 دقيقة تليها فترات راحة 5 دقائق. هذا يحافظ على إنتاجية عالية.';

  @override
  String get tip5Title => 'جمع المهام المتشابهة';

  @override
  String get tip5Description =>
      'اجمع المهام المتشابهة معاً وأكملها في جلسة واحدة لتحسين الكفاءة.';

  @override
  String get tip6Title => 'حدد أهدافاً واضحة';

  @override
  String get tip6Description =>
      'حدد أهدافاً محددة وقابلة للقياس لكل مهمة. الوضوح يؤدي إلى تنفيذ أفضل.';

  @override
  String get tip7Title => 'تخلص من المشتتات';

  @override
  String get tip7Description =>
      'أوقف الإشعارات وأنشئ بيئة عمل مركزة أثناء تنفيذ المهام.';

  @override
  String get tip8Title => 'راجع وتأمل';

  @override
  String get tip8Description =>
      'اقضِ 10 دقائق في نهاية كل يوم لمراجعة ما أنجزته والتخطيط للغد.';

  @override
  String get tip9Title => 'قاعدة 80/20';

  @override
  String get tip9Description =>
      'ركز على 20% من المهام التي ستحقق 80% من نتائجك. رتب أولوياتك بحكمة.';

  @override
  String get tip10Title => 'خذ فترات راحة منتظمة';

  @override
  String get tip10Description =>
      'فترات الراحة القصيرة تحسن التركيز وتمنع الإرهاق. عقلك يحتاج للراحة للأداء الأمثل.';

  @override
  String get tip11Title => 'التركيز على مهمة واحدة';

  @override
  String get tip11Description =>
      'ركز على مهمة واحدة في كل مرة. تعدد المهام يقلل الجودة ويزيد وقت الإنجاز.';

  @override
  String get tip12Title => 'خطط للغد اليوم';

  @override
  String get tip12Description =>
      'اقضِ 5 دقائق قبل النوم في التخطيط لمهام الغد. ستستيقظ بوضوح وهدف.';

  @override
  String insight1(Object day) {
    return 'أنت أكثر إنتاجية يوم $day. جدول المهام المهمة في هذا اليوم!';
  }

  @override
  String insight2(Object rate) {
    return 'متوسط معدل إنجاز مهامك هو $rate%. استمر في العمل الجيد!';
  }

  @override
  String insight3(Object count) {
    return 'لقد أكملت $count مهمة هذا الأسبوع. هذا رائع!';
  }

  @override
  String get insight4 =>
      'حاول تقسيم المهام الكبيرة إلى أجزاء أصغر لمعدلات إنجاز أفضل.';

  @override
  String insight5(Object duration) {
    return 'تعمل بشكل أفضل في جلسات مدتها $duration دقيقة. استخدم هذا لصالحك!';
  }
}
