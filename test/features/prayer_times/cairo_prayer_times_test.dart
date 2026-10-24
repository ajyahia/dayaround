import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jimy/features/prayer_times/data/prayer_times_service.dart';
import 'package:jimy/features/prayer_times/domain/models/app_location.dart';
import 'package:jimy/features/prayer_times/domain/models/prayer_settings.dart';

void main() {
  group('Cairo Prayer Times Accuracy', () {
    const service = PrayerTimesService();
    const cairoLocation = AppLocation(
      name: 'القاهرة',
      latitude: 30.0444,
      longitude: 31.2357,
      isAuto: false,
    );
    const settings = PrayerSettings(
      method: CalculationMethod.egyptian,
      madhab: Madhab.shafi,
    );

    test('Fixed date (2024-01-15) is within ±2 minutes of known official Egyptian values', () {
      final fixedDate = DateTime(2024, 1, 15);
      final times = service.calculatePrayerTimes(
        date: fixedDate,
        location: cairoLocation,
        settings: settings,
      );

      // Cairo is UTC+2 in winter (January 15).
      // Converting to Cairo time ensures test passes regardless of runner timezone.
      DateTime toCairo(DateTime dt) => dt.toUtc().add(const Duration(hours: 2));

      // Known official times for Cairo on 15 January:
      // Fajr: 05:20 - 05:21
      // Sunrise: 06:51 - 06:52
      // Dhuhr: 12:04 - 12:05
      // Asr: 14:58
      // Maghrib: 17:17 - 17:18
      // Isha: 18:38 - 18:39
      final knownFajr = DateTime.utc(2024, 1, 15, 5, 20);
      final knownSunrise = DateTime.utc(2024, 1, 15, 6, 52);
      final knownDhuhr = DateTime.utc(2024, 1, 15, 12, 5);
      final knownAsr = DateTime.utc(2024, 1, 15, 14, 58);
      final knownMaghrib = DateTime.utc(2024, 1, 15, 17, 18);
      final knownIsha = DateTime.utc(2024, 1, 15, 18, 39);

      expect(
        toCairo(times.fajr).difference(knownFajr).inMinutes.abs(),
        lessThanOrEqualTo(2),
        reason: 'Fajr should be within ±2 minutes of known value',
      );
      expect(
        toCairo(times.sunrise).difference(knownSunrise).inMinutes.abs(),
        lessThanOrEqualTo(2),
        reason: 'Sunrise should be within ±2 minutes of known value',
      );
      expect(
        toCairo(times.dhuhr).difference(knownDhuhr).inMinutes.abs(),
        lessThanOrEqualTo(2),
        reason: 'Dhuhr should be within ±2 minutes of known value',
      );
      expect(
        toCairo(times.asr).difference(knownAsr).inMinutes.abs(),
        lessThanOrEqualTo(2),
        reason: 'Asr should be within ±2 minutes of known value',
      );
      expect(
        toCairo(times.maghrib).difference(knownMaghrib).inMinutes.abs(),
        lessThanOrEqualTo(2),
        reason: 'Maghrib should be within ±2 minutes of known value',
      );
      expect(
        toCairo(times.isha).difference(knownIsha).inMinutes.abs(),
        lessThanOrEqualTo(2),
        reason: 'Isha should be within ±2 minutes of known value',
      );
    });

    test('Hanafi madhab delays Asr time relative to Shafi madhab', () {
      final fixedDate = DateTime(2024, 1, 15);
      final shafiTimes = service.calculatePrayerTimes(
        date: fixedDate,
        location: cairoLocation,
        settings: settings.copyWith(madhab: Madhab.shafi),
      );
      final hanafiTimes = service.calculatePrayerTimes(
        date: fixedDate,
        location: cairoLocation,
        settings: settings.copyWith(madhab: Madhab.hanafi),
      );

      expect(
        hanafiTimes.asr.isAfter(shafiTimes.asr),
        isTrue,
        reason: 'Hanafi Asr shadow ratio is 2:1 so it must be later than Shafi 1:1',
      );
      // Hanafi Asr is typically ~40-60 minutes later
      expect(
        hanafiTimes.asr.difference(shafiTimes.asr).inMinutes,
        inInclusiveRange(30, 70),
      );
    });

    test('Changing calculation method adapts Fajr and Isha parameters', () {
      final fixedDate = DateTime(2024, 1, 15);
      final egyptianTimes = service.calculatePrayerTimes(
        date: fixedDate,
        location: cairoLocation,
        settings: settings.copyWith(method: CalculationMethod.egyptian),
      );
      final ummAlQuraTimes = service.calculatePrayerTimes(
        date: fixedDate,
        location: cairoLocation,
        settings: settings.copyWith(method: CalculationMethod.umm_al_qura),
      );

      // Dhuhr is solar transit and should be within 1 minute
      expect(
        egyptianTimes.dhuhr.difference(ummAlQuraTimes.dhuhr).inMinutes.abs(),
        lessThanOrEqualTo(1),
      );

      // Egyptian survey uses 19.5 deg Fajr while Umm al-Qura uses 18.5 deg, so Egyptian Fajr is earlier
      expect(egyptianTimes.fajr.isBefore(ummAlQuraTimes.fajr), isTrue);

      // Isha in Umm al-Qura uses a fixed 90 min interval after Maghrib
      expect(
        ummAlQuraTimes.isha.difference(ummAlQuraTimes.maghrib).inMinutes,
        equals(90),
      );
    });
  });
}
