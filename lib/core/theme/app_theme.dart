import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class AppTheme {
  static const Color accentColor = CupertinoColors.systemBlue;
  static const Color destructiveColor = CupertinoColors.systemRed;

  static String? get webFontFamily =>
      kIsWeb ? GoogleFonts.ibmPlexSansArabic().fontFamily : null;

  static CupertinoThemeData get lightTheme {
    final font = webFontFamily;
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: accentColor,
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      barBackgroundColor: const Color(0xE6F2F2F7),
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 17,
          color: CupertinoColors.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4,
          color: CupertinoColors.label,
        ),
        navTitleTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: CupertinoColors.label,
        ),
        tabLabelTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static CupertinoThemeData get darkTheme {
    final font = webFontFamily;
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: accentColor,
      scaffoldBackgroundColor: CupertinoColors.black,
      barBackgroundColor: const Color(0xE61C1C1E),
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 17,
          color: CupertinoColors.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4,
          color: CupertinoColors.white,
        ),
        navTitleTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: CupertinoColors.white,
        ),
        tabLabelTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static CupertinoThemeData get systemTheme {
    final font = webFontFamily;
    return CupertinoThemeData(
      primaryColor: accentColor,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 17,
          color: CupertinoColors.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4,
        ),
        navTitleTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        tabLabelTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static CupertinoThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.system:
        return systemTheme;
    }
  }
}

class ThemeModeNotifier extends Notifier<AppThemeMode> {
  static const String _prefKey = 'app_theme_mode';
  SharedPreferences? _prefs;

  @override
  AppThemeMode build() {
    _init();
    return AppThemeMode.system;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final value = _prefs?.getString(_prefKey);
    if (value != null) {
      state = AppThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AppThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(_prefKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, AppThemeMode>(
  ThemeModeNotifier.new,
);
