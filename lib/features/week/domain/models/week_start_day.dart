enum WeekStartDay {
  saturday(DateTime.saturday, 'السبت'),
  sunday(DateTime.sunday, 'الأحد'),
  monday(DateTime.monday, 'الإثنين');

  final int weekday;
  final String labelArabic;

  const WeekStartDay(this.weekday, this.labelArabic);

  static WeekStartDay fromString(String? val) {
    if (val == null) return WeekStartDay.saturday;
    for (final day in values) {
      if (day.name == val) return day;
    }
    return WeekStartDay.saturday;
  }
}
