import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';

class PrayerTimesSection extends ConsumerWidget {
  final DateTime date;

  const PrayerTimesSection({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimes = ref.watch(prayerTimesForDateProvider(date));
    final location = ref.watch(currentLocationProvider);
    final timeFormat = DateFormat('hh:mm a', 'ar_EG');

    if (prayerTimes == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    final prayers = [
      (
        name: 'الفجر',
        time: prayerTimes.fajr,
        icon: CupertinoIcons.moon_stars_fill,
        color: CupertinoColors.systemIndigo,
      ),
      (
        name: 'الشروق',
        time: prayerTimes.sunrise,
        icon: CupertinoIcons.sunrise_fill,
        color: CupertinoColors.systemOrange,
      ),
      (
        name: 'الظهر',
        time: prayerTimes.dhuhr,
        icon: CupertinoIcons.sun_max_fill,
        color: CupertinoColors.systemYellow,
      ),
      (
        name: 'العصر',
        time: prayerTimes.asr,
        icon: CupertinoIcons.sun_haze_fill,
        color: CupertinoColors.systemTeal,
      ),
      (
        name: 'المغرب',
        time: prayerTimes.maghrib,
        icon: CupertinoIcons.sunset_fill,
        color: CupertinoColors.systemPink,
      ),
      (
        name: 'العشاء',
        time: prayerTimes.isha,
        icon: CupertinoIcons.moon_fill,
        color: CupertinoColors.systemPurple,
      ),
    ];

    return CupertinoListSection.insetGrouped(
      header: Text('مواقيت الصلاة • ${location.name}'),
      children: prayers.map((p) {
        return CupertinoListTile(
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: p.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(p.icon, size: 16, color: p.color),
          ),
          title: Text(
            p.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: Text(
            timeFormat.format(p.time),
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}
