import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jimy/features/prayer_times/data/location_service.dart';
import 'package:jimy/features/prayer_times/data/prayer_times_service.dart';
import 'package:jimy/features/prayer_times/domain/models/app_location.dart';
import 'package:jimy/features/prayer_times/domain/models/day_block.dart';
import 'package:jimy/features/prayer_times/domain/models/next_prayer_info.dart';
import 'package:jimy/features/prayer_times/domain/models/prayer_settings.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final prayerTimesServiceProvider = Provider<PrayerTimesService>((ref) {
  return const PrayerTimesService();
});

/// Current Location Notifier using modern Riverpod Notifier
class CurrentLocationNotifier extends Notifier<AppLocation> {
  @override
  AppLocation build() {
    _loadCached();
    return LocationService.defaultLocation;
  }

  Future<void> _loadCached() async {
    final service = ref.read(locationServiceProvider);
    final loc = await service.getCachedLocation();
    state = loc;
  }

  Future<void> setLocation(AppLocation location) async {
    final service = ref.read(locationServiceProvider);
    await service.cacheLocation(location);
    state = location;
  }

  Future<bool> detectAutoLocation() async {
    final service = ref.read(locationServiceProvider);
    final autoLoc = await service.requestAutoLocation();
    if (autoLoc != null) {
      state = autoLoc;
      return true;
    }
    return false;
  }
}

final currentLocationProvider =
    NotifierProvider<CurrentLocationNotifier, AppLocation>(
  CurrentLocationNotifier.new,
);

/// Prayer Settings Notifier using modern Riverpod Notifier
class PrayerSettingsNotifier extends Notifier<PrayerSettings> {
  static const String _keyMethod = 'prayer_calc_method';
  static const String _keyMadhab = 'prayer_asr_madhab';

  @override
  PrayerSettings build() {
    _loadFromPrefs();
    return const PrayerSettings();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final methodStr = prefs.getString(_keyMethod);
    final madhabStr = prefs.getString(_keyMadhab);

    state = PrayerSettings(
      method: PrayerSettings.methodFromString(methodStr),
      madhab: PrayerSettings.madhabFromString(madhabStr),
    );
  }

  Future<void> updateMethod(CalculationMethod method) async {
    state = state.copyWith(method: method);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMethod, method.name);
  }

  Future<void> updateMadhab(Madhab madhab) async {
    state = state.copyWith(madhab: madhab);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMadhab, madhab.name);
  }
}

final prayerSettingsProvider =
    NotifierProvider<PrayerSettingsNotifier, PrayerSettings>(
  PrayerSettingsNotifier.new,
);

/// Prayer times for a specific date
final prayerTimesForDateProvider =
    Provider.family<PrayerTimes?, DateTime>((ref, date) {
  final location = ref.watch(currentLocationProvider);
  final settings = ref.watch(prayerSettingsProvider);
  final service = ref.watch(prayerTimesServiceProvider);

  return service.calculatePrayerTimes(
    date: date,
    location: location,
    settings: settings,
  );
});

/// Day blocks for a specific date
final dayBlocksProvider = Provider.family<List<DayBlock>, DateTime>((ref, date) {
  final prayerTimes = ref.watch(prayerTimesForDateProvider(date));
  if (prayerTimes == null) return [];
  return calculateDayBlocks(prayerTimes, date: date);
});

/// Periodic tick for live countdown
final currentTimeProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

/// Next prayer information with live countdown
final nextPrayerProvider = Provider.autoDispose<NextPrayerInfo?>((ref) {
  final nowAsync = ref.watch(currentTimeProvider);
  final now = nowAsync.value ?? DateTime.now();
  final todayTimes = ref.watch(prayerTimesForDateProvider(now));
  if (todayTimes == null) return null;

  final tomorrow = now.add(const Duration(days: 1));
  final tomorrowTimes = ref.watch(prayerTimesForDateProvider(tomorrow));
  if (tomorrowTimes == null) return null;

  final next = todayTimes.nextPrayer();
  if (next != Prayer.none) {
    final nextTime = todayTimes.timeForPrayer(next);
    if (nextTime != null) {
      return NextPrayerInfo(
        prayer: next,
        prayerNameArabic: NextPrayerInfo.getPrayerArabicName(next),
        prayerTime: nextTime,
        timeRemaining: nextTime.difference(now),
      );
    }
  }

  // After Isha, next prayer is tomorrow's Fajr
  final tomorrowFajr = tomorrowTimes.fajr;
  return NextPrayerInfo(
    prayer: Prayer.fajr,
    prayerNameArabic: 'الفجر',
    prayerTime: tomorrowFajr,
    timeRemaining: tomorrowFajr.difference(now),
  );
});
