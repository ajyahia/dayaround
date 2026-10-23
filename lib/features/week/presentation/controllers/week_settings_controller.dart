import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimy/features/week/domain/models/week_start_day.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeekStartDayNotifier extends Notifier<WeekStartDay> {
  static const String _key = 'week_start_day_setting';

  @override
  WeekStartDay build() {
    _loadFromPrefs();
    return WeekStartDay.saturday;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    state = WeekStartDay.fromString(saved);
  }

  Future<void> update(WeekStartDay day) async {
    state = day;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, day.name);
  }
}

final weekStartDayProvider =
    NotifierProvider<WeekStartDayNotifier, WeekStartDay>(
  WeekStartDayNotifier.new,
);
