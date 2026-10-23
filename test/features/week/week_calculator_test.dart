import 'package:flutter_test/flutter_test.dart';
import 'package:jimy/features/week/domain/models/week_start_day.dart';
import 'package:jimy/features/week/domain/week_calculator.dart';

void main() {
  group('WeekCalculator Tests', () {
    test('Week start with Saturday setting', () {
      // 2026-10-24 is Saturday
      final saturday = DateTime(2026, 10, 24);
      final weekStart1 = WeekCalculator.getWeekStart(saturday, WeekStartDay.saturday);
      expect(weekStart1.year, 2026);
      expect(weekStart1.month, 10);
      expect(weekStart1.day, 24);

      // 2026-10-28 is Wednesday
      final wednesday = DateTime(2026, 10, 28);
      final weekStart2 = WeekCalculator.getWeekStart(wednesday, WeekStartDay.saturday);
      expect(weekStart2.day, 24);

      // 2026-10-30 is Friday (last day of the week)
      final friday = DateTime(2026, 10, 30);
      final weekStart3 = WeekCalculator.getWeekStart(friday, WeekStartDay.saturday);
      expect(weekStart3.day, 24);
    });

    test('Week start with Sunday setting', () {
      // 2026-10-25 is Sunday
      final sunday = DateTime(2026, 10, 25);
      final weekStart = WeekCalculator.getWeekStart(sunday, WeekStartDay.sunday);
      expect(weekStart.day, 25);

      // 2026-10-24 is Saturday (last day of previous week starting Sunday)
      final saturday = DateTime(2026, 10, 24);
      final weekStartSat = WeekCalculator.getWeekStart(saturday, WeekStartDay.sunday);
      expect(weekStartSat.day, 18); // Previous Sunday
    });

    test('Week start with Monday setting', () {
      // 2026-10-26 is Monday
      final monday = DateTime(2026, 10, 26);
      final weekStart = WeekCalculator.getWeekStart(monday, WeekStartDay.monday);
      expect(weekStart.day, 26);
    });

    test('getWeekDays generates 7 consecutive days', () {
      final start = DateTime(2026, 10, 24);
      final days = WeekCalculator.getWeekDays(start);

      expect(days.length, 7);
      expect(days[0].day, 24);
      expect(days[1].day, 25);
      expect(days[2].day, 26);
      expect(days[3].day, 27);
      expect(days[4].day, 28);
      expect(days[5].day, 29);
      expect(days[6].day, 30);
    });

    test('getWeekNumber and getWeekTitleArabic', () {
      final date = DateTime(2026, 10, 24);
      final weekNum = WeekCalculator.getWeekNumber(date);
      expect(weekNum, isPositive);
      expect(weekNum, lessThanOrEqualTo(53));

      final title = WeekCalculator.getWeekTitleArabic(date);
      expect(title, startsWith('الأسبوع '));
      expect(title, endsWith(' من السنة'));
    });
  });
}
