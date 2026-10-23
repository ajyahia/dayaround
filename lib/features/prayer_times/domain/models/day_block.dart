import 'package:adhan/adhan.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';

class DayBlock {
  final PrayerBlockType id;
  final String label;
  final DateTime start;
  final DateTime end;
  final int durationMinutes;
  final DateTime? sunrise;

  const DayBlock({
    required this.id,
    required this.label,
    required this.start,
    required this.end,
    required this.durationMinutes,
    this.sunrise,
  });

  bool contains(DateTime time) {
    return (time.isAfter(start) || time.isAtSameMomentAs(start)) &&
        time.isBefore(end);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayBlock &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          start == other.start &&
          end == other.end &&
          durationMinutes == other.durationMinutes &&
          sunrise == other.sunrise;

  @override
  int get hashCode =>
      id.hashCode ^
      label.hashCode ^
      start.hashCode ^
      end.hashCode ^
      durationMinutes.hashCode ^
      sunrise.hashCode;

  @override
  String toString() =>
      'DayBlock(id: $id, label: $label, start: $start, end: $end, duration: $durationMinutes min)';
}

/// Pure function converting a day's prayer times into the six blocks in the brief
List<DayBlock> calculateDayBlocks(PrayerTimes prayerTimes, {DateTime? date}) {
  final baseDate = date ?? prayerTimes.fajr;
  final startOfDay = DateTime(baseDate.year, baseDate.month, baseDate.day, 0, 0, 0);
  final endOfDay = DateTime(baseDate.year, baseDate.month, baseDate.day, 23, 59, 59);

  return [
    DayBlock(
      id: PrayerBlockType.beforeFajr,
      label: 'قيام الليل',
      start: startOfDay,
      end: prayerTimes.fajr,
      durationMinutes: prayerTimes.fajr.difference(startOfDay).inMinutes,
    ),
    DayBlock(
      id: PrayerBlockType.afterFajr,
      label: 'الفجر',
      start: prayerTimes.fajr,
      end: prayerTimes.dhuhr,
      durationMinutes: prayerTimes.dhuhr.difference(prayerTimes.fajr).inMinutes,
      sunrise: prayerTimes.sunrise,
    ),
    DayBlock(
      id: PrayerBlockType.afterDhuhr,
      label: 'الظهر',
      start: prayerTimes.dhuhr,
      end: prayerTimes.asr,
      durationMinutes: prayerTimes.asr.difference(prayerTimes.dhuhr).inMinutes,
    ),
    DayBlock(
      id: PrayerBlockType.afterAsr,
      label: 'العصر',
      start: prayerTimes.asr,
      end: prayerTimes.maghrib,
      durationMinutes: prayerTimes.maghrib.difference(prayerTimes.asr).inMinutes,
    ),
    DayBlock(
      id: PrayerBlockType.afterMaghrib,
      label: 'المغرب',
      start: prayerTimes.maghrib,
      end: prayerTimes.isha,
      durationMinutes: prayerTimes.isha.difference(prayerTimes.maghrib).inMinutes,
    ),
    DayBlock(
      id: PrayerBlockType.afterIsha,
      label: 'العشاء',
      start: prayerTimes.isha,
      end: endOfDay,
      durationMinutes: endOfDay.difference(prayerTimes.isha).inMinutes,
    ),
  ];
}
