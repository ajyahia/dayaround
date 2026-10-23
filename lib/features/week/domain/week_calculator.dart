import 'package:jimy/features/week/domain/models/week_start_day.dart';

class WeekCalculator {
  const WeekCalculator._();

  /// Returns the start date (00:00:00) of the week containing [date] based on [startDay].
  static DateTime getWeekStart(DateTime date, WeekStartDay startDay) {
    int diff = date.weekday - startDay.weekday;
    if (diff < 0) {
      diff += 7;
    }
    return DateTime(date.year, date.month, date.day - diff);
  }

  /// Returns the 7 days of the week starting from [weekStart].
  static List<DateTime> getWeekDays(DateTime weekStart) {
    return List.generate(
      7,
      (i) => DateTime(weekStart.year, weekStart.month, weekStart.day + i),
    );
  }

  /// Returns the calendar week number of the year (1 - 53).
  static int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final days = date.difference(firstDayOfYear).inDays;
    final weekNum = ((days + firstDayOfYear.weekday) / 7).ceil();
    return weekNum.clamp(1, 53);
  }

  /// Formatted Arabic week title (e.g. "الأسبوع 43 من السنة")
  static String getWeekTitleArabic(DateTime date) {
    final weekNum = getWeekNumber(date);
    return 'الأسبوع $weekNum من السنة';
  }
}
