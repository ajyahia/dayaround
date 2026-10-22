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
  String get todayPlaceholder => 'جدول اليوم سيظهر هنا';

  @override
  String get weekPlaceholder => 'عرض الأسبوع سيظهر هنا';
}
