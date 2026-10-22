// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'جيمي';

  @override
  String get todayTab => 'اليوم';

  @override
  String get weekTab => 'الأسبوع';

  @override
  String get settingsTab => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get appearanceFooter =>
      'يحدد المظهر الوضع الفاتح أو الداكن للتطبيق، أو يتبع إعدادات جهازك تلقائياً.';

  @override
  String get todayPlaceholder => 'جدول اليوم سيظهر هنا';

  @override
  String get weekPlaceholder => 'عرض الأسبوع سيظهر هنا';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String get todayTasks => 'مهام اليوم';

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String get noTasks => 'لا توجد مهام';

  @override
  String get now => 'الآن';

  @override
  String get minShort => 'د';

  @override
  String get soon => 'قريبًا';

  @override
  String get privacyNote => 'كل بياناتك محفوظة على جهازك فقط.';

  @override
  String get location => 'الموقع';

  @override
  String get calcMethod => 'طريقة الحساب';

  @override
  String get asrMadhab => 'مذهب العصر';

  @override
  String get weekStart => 'بداية الأسبوع';

  @override
  String get blockBeforeFajr => 'قبل الفجر';

  @override
  String get blockAfterFajr => 'بعد الفجر';

  @override
  String get blockAfterDhuhr => 'بعد الظهر';

  @override
  String get blockAfterAsr => 'بعد العصر';

  @override
  String get blockAfterMaghrib => 'بعد المغرب';

  @override
  String get blockAfterIsha => 'بعد العشاء';
}
