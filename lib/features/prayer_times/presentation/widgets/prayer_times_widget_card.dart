import 'package:adhan/adhan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';

class PrayerTimesWidgetCard extends ConsumerWidget {
  final DateTime date;
  final VoidCallback? onTap;

  const PrayerTimesWidgetCard({
    super.key,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPrayer = ref.watch(nextPrayerProvider);
    final prayerTimes = ref.watch(prayerTimesForDateProvider(date));
    final location = ref.watch(currentLocationProvider);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    // Hijri date
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(date);
    final hijriText = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';

    final timeFormat = DateFormat('h:mm a', 'ar_EG');

    // Deep modern widget background
    final cardBg = isDark ? const Color(0xFF182232) : const Color(0xFF1E293B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0x22FFFFFF),
            width: 0.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section (Image 1 style)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Icon, Hijri date, City
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mosque/Lantern/Alarm icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0x22FFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.alarm_fill,
                          color: Color(0xFFE2E8F0),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hijriText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Right side: Next prayer name & big countdown timer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      nextPrayer != null
                          ? '${nextPrayer.prayerNameArabic} بعد'
                          : 'الصلاة بعد',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextPrayer?.formatRemainingCountdown() ?? '--:--:--',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Bottom Section: Horizontal Side-by-Side Prayers (Image 1 style)
            if (prayerTimes != null) ...[
              Builder(
                builder: (context) {
                  final activePrayer = nextPrayer?.prayer;

                  final prayers = [
                    (
                      prayer: Prayer.fajr,
                      name: 'الفجر',
                      time: prayerTimes.fajr,
                      icon: CupertinoIcons.moon_stars_fill,
                    ),
                    (
                      prayer: Prayer.sunrise,
                      name: 'الشروق',
                      time: prayerTimes.sunrise,
                      icon: CupertinoIcons.sunrise_fill,
                    ),
                    (
                      prayer: Prayer.dhuhr,
                      name: 'الظهر',
                      time: prayerTimes.dhuhr,
                      icon: CupertinoIcons.sun_max_fill,
                    ),
                    (
                      prayer: Prayer.asr,
                      name: 'العصر',
                      time: prayerTimes.asr,
                      icon: CupertinoIcons.sun_haze_fill,
                    ),
                    (
                      prayer: Prayer.maghrib,
                      name: 'المغرب',
                      time: prayerTimes.maghrib,
                      icon: CupertinoIcons.sunset_fill,
                    ),
                    (
                      prayer: Prayer.isha,
                      name: 'العشاء',
                      time: prayerTimes.isha,
                      icon: CupertinoIcons.moon_fill,
                    ),
                  ];

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: prayers.map((p) {
                      final isSelected = activePrayer == p.prayer;

                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0x33FFFFFF)
                                : CupertinoColors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0x44FFFFFF),
                                    width: 1.0,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                p.icon,
                                size: 18,
                                color: isSelected
                                    ? CupertinoColors.white
                                    : const Color(0xFFCBD5E1),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeFormat.format(p.time),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? CupertinoColors.white
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
