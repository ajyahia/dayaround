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

  static Color getPrayerColor(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return CupertinoColors.systemOrange;
      case Prayer.sunrise:
        return const Color(0xFFFF9F0A);
      case Prayer.dhuhr:
        return CupertinoColors.systemYellow;
      case Prayer.asr:
        return CupertinoColors.systemTeal;
      case Prayer.maghrib:
        return CupertinoColors.systemPink;
      case Prayer.isha:
        return CupertinoColors.systemPurple;
      case Prayer.none:
        return CupertinoColors.systemOrange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPrayer = ref.watch(nextPrayerProvider);
    final prayerTimes = ref.watch(prayerTimesForDateProvider(date));
    final location = ref.watch(currentLocationProvider);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    final activePrayer = nextPrayer?.prayer ?? Prayer.none;
    final activeColor = getPrayerColor(activePrayer);

    // Hijri date
    HijriCalendar.setLocal('ar');
    final hijri = HijriCalendar.fromDate(date);
    final hijriText = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';

    final timeFormat = DateFormat('h:mm a', 'ar_EG');

    // Deep modern widget background
    final cardBg = isDark ? const Color(0xFF141C28) : const Color(0xFF1A2332);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: activeColor.withValues(alpha: 0.35),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x38000000),
              blurRadius: 18,
              offset: const Offset(0, 6),
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
                    // Mosque/Lantern/Alarm icon tinted with active prayer color
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.alarm_fill,
                          color: activeColor,
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: activeColor,
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

            // Bottom Section: Horizontal Side-by-Side Prayers with respective colors (Image 1 style)
            if (prayerTimes != null) ...[
              Builder(
                builder: (context) {
                  final prayers = [
                    (
                      prayer: Prayer.fajr,
                      name: 'الفجر',
                      time: prayerTimes.fajr,
                      icon: CupertinoIcons.moon_stars_fill,
                      color: CupertinoColors.systemOrange,
                    ),
                    (
                      prayer: Prayer.sunrise,
                      name: 'الشروق',
                      time: prayerTimes.sunrise,
                      icon: CupertinoIcons.sunrise_fill,
                      color: const Color(0xFFFF9F0A),
                    ),
                    (
                      prayer: Prayer.dhuhr,
                      name: 'الظهر',
                      time: prayerTimes.dhuhr,
                      icon: CupertinoIcons.sun_max_fill,
                      color: CupertinoColors.systemYellow,
                    ),
                    (
                      prayer: Prayer.asr,
                      name: 'العصر',
                      time: prayerTimes.asr,
                      icon: CupertinoIcons.sun_haze_fill,
                      color: CupertinoColors.systemTeal,
                    ),
                    (
                      prayer: Prayer.maghrib,
                      name: 'المغرب',
                      time: prayerTimes.maghrib,
                      icon: CupertinoIcons.sunset_fill,
                      color: CupertinoColors.systemPink,
                    ),
                    (
                      prayer: Prayer.isha,
                      name: 'العشاء',
                      time: prayerTimes.isha,
                      icon: CupertinoIcons.moon_fill,
                      color: CupertinoColors.systemPurple,
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
                                ? p.color.withValues(alpha: 0.22)
                                : CupertinoColors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: isSelected
                                ? Border.all(
                                    color: p.color.withValues(alpha: 0.65),
                                    width: 1.2,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                p.icon,
                                size: 19,
                                color: p.color,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? p.color
                                      : CupertinoColors.white,
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
