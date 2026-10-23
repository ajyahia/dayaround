import 'package:adhan/adhan.dart';

class NextPrayerInfo {
  final Prayer prayer;
  final String prayerNameArabic;
  final DateTime prayerTime;
  final Duration timeRemaining;

  const NextPrayerInfo({
    required this.prayer,
    required this.prayerNameArabic,
    required this.prayerTime,
    required this.timeRemaining,
  });

  static String getPrayerArabicName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      case Prayer.none:
        return 'الفجر';
    }
  }

  String formatRemainingCountdown() {
    final totalSeconds = timeRemaining.inSeconds;
    if (totalSeconds <= 0) return 'حان وقت الأذان';
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes.remainder(60);
    final seconds = totalSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String formatRelativeDescription() {
    final totalSeconds = timeRemaining.inSeconds;
    if (totalSeconds <= 0) return 'حان وقت الأذان';
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return 'بعد $hours س و $minutes د';
    } else if (hours > 0) {
      return 'بعد $hours س';
    } else if (minutes > 0) {
      return 'بعد $minutes د';
    } else {
      return 'أقل من دقيقة';
    }
  }
}
