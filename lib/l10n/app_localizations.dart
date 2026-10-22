import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// اسم التطبيق
  ///
  /// In ar, this message translates to:
  /// **'جيمي'**
  String get appTitle;

  /// عنوان تبويب اليوم
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get todayTab;

  /// عنوان تبويب الأسبوع
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع'**
  String get weekTab;

  /// عنوان تبويب الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTab;

  /// عنوان خيار المظهر في الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// خيار مظهر النظام التلقائي
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get themeSystem;

  /// خيار المظهر الفاتح
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// خيار المظهر الداكن
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// وصف خيارات المظهر
  ///
  /// In ar, this message translates to:
  /// **'يحدد المظهر الوضع الفاتح أو الداكن للتطبيق، أو يتبع إعدادات جهازك تلقائياً.'**
  String get appearanceFooter;

  /// نص تجريبي لتبويب اليوم
  ///
  /// In ar, this message translates to:
  /// **'جدول اليوم سيظهر هنا'**
  String get todayPlaceholder;

  /// نص تجريبي لتبويب الأسبوع
  ///
  /// In ar, this message translates to:
  /// **'عرض الأسبوع سيظهر هنا'**
  String get weekPlaceholder;

  /// عنوان بطاقة الصلاة القادمة
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get nextPrayer;

  /// عنوان بطاقة مهام اليوم
  ///
  /// In ar, this message translates to:
  /// **'مهام اليوم'**
  String get todayTasks;

  /// زر إضافة مهمة جديدة
  ///
  /// In ar, this message translates to:
  /// **'مهمة جديدة'**
  String get newTask;

  /// نص الحالة الفارغة للكتلة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام'**
  String get noTasks;

  /// شارة الكتلة الحالية
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get now;

  /// اختصار دقيقة
  ///
  /// In ar, this message translates to:
  /// **'د'**
  String get minShort;

  /// قريباً للميزات القادمة
  ///
  /// In ar, this message translates to:
  /// **'قريبًا'**
  String get soon;

  /// ملاحظة الخصوصية في الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'كل بياناتك محفوظة على جهازك فقط.'**
  String get privacyNote;

  /// إعداد الموقع
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location;

  /// إعداد طريقة حساب أوقات الصلاة
  ///
  /// In ar, this message translates to:
  /// **'طريقة الحساب'**
  String get calcMethod;

  /// إعداد مذهب حساب صلاة العصر
  ///
  /// In ar, this message translates to:
  /// **'مذهب العصر'**
  String get asrMadhab;

  /// إعداد يوم بداية الأسبوع
  ///
  /// In ar, this message translates to:
  /// **'بداية الأسبوع'**
  String get weekStart;

  /// اسم كتلة قبل الفجر
  ///
  /// In ar, this message translates to:
  /// **'قبل الفجر'**
  String get blockBeforeFajr;

  /// اسم كتلة بعد الفجر
  ///
  /// In ar, this message translates to:
  /// **'بعد الفجر'**
  String get blockAfterFajr;

  /// اسم كتلة بعد الظهر
  ///
  /// In ar, this message translates to:
  /// **'بعد الظهر'**
  String get blockAfterDhuhr;

  /// اسم كتلة بعد العصر
  ///
  /// In ar, this message translates to:
  /// **'بعد العصر'**
  String get blockAfterAsr;

  /// اسم كتلة بعد المغرب
  ///
  /// In ar, this message translates to:
  /// **'بعد المغرب'**
  String get blockAfterMaghrib;

  /// اسم كتلة بعد العشاء
  ///
  /// In ar, this message translates to:
  /// **'بعد العشاء'**
  String get blockAfterIsha;
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
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
