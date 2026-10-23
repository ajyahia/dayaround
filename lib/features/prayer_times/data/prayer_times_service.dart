import 'package:adhan/adhan.dart';
import 'package:jimy/features/prayer_times/domain/models/app_location.dart';
import 'package:jimy/features/prayer_times/domain/models/prayer_settings.dart';

class PrayerTimesService {
  const PrayerTimesService();

  PrayerTimes calculatePrayerTimes({
    required DateTime date,
    required AppLocation location,
    required PrayerSettings settings,
  }) {
    final coordinates = Coordinates(location.latitude, location.longitude);
    final params = settings.method.getParameters();
    params.madhab = settings.madhab;
    final dateComponents = DateComponents.from(date);

    return PrayerTimes(coordinates, dateComponents, params);
  }
}
