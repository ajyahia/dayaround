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
      label: 'قيام الليل',
      defaultTimeRange: '12:00 ص',
      color: CupertinoColors.systemIndigo,
      icon: CupertinoIcons.moon_stars_fill,
    ),
    PrayerBlockInfo(
      type: PrayerBlockType.afterFajr,
      label: 'الفجر',
      defaultTimeRange: '04:30 ص',
      color: CupertinoColors.systemOrange,
      icon: CupertinoIcons.sunrise_fill,
    ),
    PrayerBlockInfo(
      type: PrayerBlockType.afterDhuhr,
      label: 'الظهر',
      defaultTimeRange: '11:45 ص',
      color: CupertinoColors.systemYellow,
      icon: CupertinoIcons.sun_max_fill,
    ),
    PrayerBlockInfo(
      type: PrayerBlockType.afterAsr,
      label: 'العصر',
      defaultTimeRange: '03:00 م',
      color: CupertinoColors.systemTeal,
      icon: CupertinoIcons.sun_haze_fill,
    ),
    PrayerBlockInfo(
      type: PrayerBlockType.afterMaghrib,
      label: 'المغرب',
      defaultTimeRange: '05:45 م',
      color: CupertinoColors.systemPink,
      icon: CupertinoIcons.sunset_fill,
    ),
    PrayerBlockInfo(
      type: PrayerBlockType.afterIsha,
      label: 'العشاء',
      defaultTimeRange: '07:15 م',
      color: CupertinoColors.systemPurple,
      icon: CupertinoIcons.moon_fill,
    ),
  ];
}

extension PrayerBlockTypeExtension on PrayerBlockType {
  PrayerBlockInfo get info =>
      PrayerBlockInfo.allBlocks.firstWhere((b) => b.type == this);

  String get label => info.label;
  Color get color => info.color;
  IconData get icon => info.icon;
}
