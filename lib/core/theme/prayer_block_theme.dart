import 'package:flutter/cupertino.dart';

enum PrayerBlockType {
  beforeFajr,
  afterFajr,
  afterDhuhr,
  afterAsr,
  afterMaghrib,
  afterIsha,
}

class PrayerBlockInfo {
  final PrayerBlockType type;
  final String label;
  final String defaultTimeRange;
  final Color color;
  final IconData icon;

  const PrayerBlockInfo({
    required this.type,
    required this.label,
    required this.defaultTimeRange,
    required this.color,
    required this.icon,
  });

  static const List<PrayerBlockInfo> allBlocks = [
    PrayerBlockInfo(
      type: PrayerBlockType.beforeFajr,
      label: 'قبل الفجر',
      defaultTimeRange: '00:00 - 04:30',
      color: CupertinoColors.systemIndigo,
      icon: CupertinoIcons.moon_stars_fill,
    ),
    PrayerBlockInfo(
      type: PrayerBlockType.afterFajr,
      label: 'بعد الفجر',
      defaultTimeRange: '04:30 - 11:45',
      color: CupertinoColors.systemOrange,
      icon: CupertinoIcons.sunrise_fill,
    ),
    PrayerBlockInfo(
      type: PrayerBlockType.afterDhuhr,
      label: 'بعد الظهر',
      defaultTimeRange: '11:45 - 03:00',
      color: CupertinoColors.systemYellow,
      icon: CupertinoIcons.sun_max_fill,
    ),
    PrayerBlockInfo(
      type: PrayerBlockType.afterAsr,
      label: 'بعد العصر',
      defaultTimeRange: '03:00 - 05:45',
      color: CupertinoColors.systemTeal,
      icon: CupertinoIcons.sun_haze_fill,
    ),
    PrayerBlockInfo(
      type: PrayerBlockType.afterMaghrib,
      label: 'بعد المغرب',
      defaultTimeRange: '05:45 - 07:15',
      color: CupertinoColors.systemPink,
      icon: CupertinoIcons.sunset_fill,
    ),
    PrayerBlockInfo(
      type: PrayerBlockType.afterIsha,
      label: 'بعد العشاء',
      defaultTimeRange: '07:15 - 23:59',
      color: CupertinoColors.systemPurple,
      icon: CupertinoIcons.moon_fill,
    ),
  ];
}
