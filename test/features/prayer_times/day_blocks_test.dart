import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';
import 'package:jimy/features/prayer_times/domain/models/day_block.dart';

void main() {
  group('DayBlocks calculateDayBlocks', () {
    late PrayerTimes prayerTimes;

    setUp(() {
      final coordinates = Coordinates(30.0444, 31.2357);
      final params = CalculationMethod.egyptian.getParameters();
      params.madhab = Madhab.shafi;
      final date = DateComponents(2024, 1, 15);
      prayerTimes = PrayerTimes(coordinates, date, params);
    });

    test('generates exactly 6 continuous blocks in correct order with correct labels', () {
      final blocks = calculateDayBlocks(prayerTimes);

      expect(blocks.length, equals(6));

      expect(blocks[0].id, equals(PrayerBlockType.beforeFajr));
      expect(blocks[0].label, equals('قبل الفجر'));
      expect(blocks[0].start.hour, equals(0));
      expect(blocks[0].start.minute, equals(0));
      expect(blocks[0].end, equals(prayerTimes.fajr));

      expect(blocks[1].id, equals(PrayerBlockType.afterFajr));
      expect(blocks[1].label, equals('بعد الفجر'));
      expect(blocks[1].start, equals(prayerTimes.fajr));
      expect(blocks[1].end, equals(prayerTimes.dhuhr));
      expect(blocks[1].sunrise, equals(prayerTimes.sunrise));

      expect(blocks[2].id, equals(PrayerBlockType.afterDhuhr));
      expect(blocks[2].label, equals('بعد الظهر'));
      expect(blocks[2].start, equals(prayerTimes.dhuhr));
      expect(blocks[2].end, equals(prayerTimes.asr));

      expect(blocks[3].id, equals(PrayerBlockType.afterAsr));
      expect(blocks[3].label, equals('بعد العصر'));
      expect(blocks[3].start, equals(prayerTimes.asr));
      expect(blocks[3].end, equals(prayerTimes.maghrib));

      expect(blocks[4].id, equals(PrayerBlockType.afterMaghrib));
      expect(blocks[4].label, equals('بعد المغرب'));
      expect(blocks[4].start, equals(prayerTimes.maghrib));
      expect(blocks[4].end, equals(prayerTimes.isha));

      expect(blocks[5].id, equals(PrayerBlockType.afterIsha));
      expect(blocks[5].label, equals('بعد العشاء'));
      expect(blocks[5].start, equals(prayerTimes.isha));
      expect(blocks[5].end.hour, equals(23));
      expect(blocks[5].end.minute, equals(59));
    });

    test('every block end matches the next block start', () {
      final blocks = calculateDayBlocks(prayerTimes);

      for (int i = 0; i < blocks.length - 1; i++) {
        expect(blocks[i].end, equals(blocks[i + 1].start));
      }
    });

    test('total duration of day blocks approximately equals 1440 minutes', () {
      final blocks = calculateDayBlocks(prayerTimes);
      final totalMinutes = blocks.fold<int>(0, (sum, b) => sum + b.durationMinutes);

      // 23:59:59 is 1439 full minutes
      expect(totalMinutes, inInclusiveRange(1438, 1440));
    });

    test('contains helper correctly identifies timestamp inside block', () {
      final blocks = calculateDayBlocks(prayerTimes);
      final afterFajrBlock = blocks[1];

      // Time right after fajr
      final testTimeInside = prayerTimes.fajr.add(const Duration(minutes: 10));
      expect(afterFajrBlock.contains(testTimeInside), isTrue);

      // Time before fajr
      final testTimeBefore = prayerTimes.fajr.subtract(const Duration(minutes: 10));
      expect(afterFajrBlock.contains(testTimeBefore), isFalse);
    });
  });
}
