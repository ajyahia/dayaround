import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class AppTheme {
  static const Color accentColor = Color(0xFF38BDF8); // Vibrant sky blue
  static const Color destructiveColor = Color(0xFFEF4444);

  /// Beautiful Arabic typography with Tajawal font
  static String? get fontFamily => GoogleFonts.tajawal().fontFamily;

  static CupertinoThemeData get lightTheme {
    final font = fontFamily;
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF0284C7),
      scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Slate 100
      barBackgroundColor: const Color(0xF2FFFFFF),
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 16,
          color: const Color(0xFF0F172A),
        ),
        navLargeTitleTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4,
          color: const Color(0xFF0F172A),
        ),
        navTitleTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: const Color(0xFF0F172A),
        ),
        tabLabelTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static CupertinoThemeData get darkTheme {
    final font = fontFamily;
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF38BDF8),
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Premium Dark Slate 900
      barBackgroundColor: const Color(0xF01E293B),
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 16,
          color: const Color(0xFFF8FAFC), // High-contrast clean off-white
        ),
        navLargeTitleTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4,
          color: const Color(0xFFF8FAFC),
        ),
        navTitleTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: const Color(0xFFF8FAFC),
        ),
        tabLabelTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static CupertinoThemeData get systemTheme {
    final font = fontFamily;
    return CupertinoThemeData(
      primaryColor: const Color(0xFF0284C7),
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 16,
          color: CupertinoColors.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          inherit: false,
          fontFamily: font,
          fontSize: 32,
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
          fontSize: 11,
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
