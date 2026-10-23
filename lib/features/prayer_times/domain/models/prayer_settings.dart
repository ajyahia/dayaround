import 'package:adhan/adhan.dart';

class PrayerSettings {
  final CalculationMethod method;
  final Madhab madhab;

  const PrayerSettings({
    this.method = CalculationMethod.egyptian,
    this.madhab = Madhab.shafi,
  });

  PrayerSettings copyWith({
    CalculationMethod? method,
    Madhab? madhab,
  }) {
    return PrayerSettings(
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
    );
  }

  static String getMethodArabicName(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.egyptian:
        return 'الهيئة المصرية العامة للمساحة';
      case CalculationMethod.umm_al_qura:
        return 'جامعة أم القرى (مكة المكرمة)';
      case CalculationMethod.muslim_world_league:
        return 'رابطة العالم الإسلامي';
      case CalculationMethod.dubai:
        return 'دبي (الإمارات)';
      case CalculationMethod.kuwait:
        return 'الكويت';
      case CalculationMethod.qatar:
        return 'قطر';
      case CalculationMethod.karachi:
        return 'جامعة العلوم الإسلامية (كراتشي)';
      case CalculationMethod.singapore:
        return 'سنغافورة (MUIS)';
      case CalculationMethod.turkey:
        return 'رئاسة الشؤون الدينية (تركيا)';
      case CalculationMethod.tehran:
        return 'معهد الجيوفيزياء (طهران)';
      case CalculationMethod.north_america:
        return 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)';
      case CalculationMethod.moon_sighting_committee:
        return 'لجنة رؤية الهلال';
      case CalculationMethod.other:
        return 'أخرى / مخصص';
    }
  }

  static String getMadhabArabicName(Madhab madhab) {
    switch (madhab) {
      case Madhab.shafi:
        return 'الشافعي / المالكي / الحنبلي (الجمهور)';
      case Madhab.hanafi:
        return 'الحنفي';
    }
  }

  static CalculationMethod methodFromString(String? name) {
    if (name == null) return CalculationMethod.egyptian;
    for (final m in CalculationMethod.values) {
      if (m.name == name) return m;
    }
    return CalculationMethod.egyptian;
  }

  static Madhab madhabFromString(String? name) {
    if (name == null) return Madhab.shafi;
    for (final m in Madhab.values) {
      if (m.name == name) return m;
    }
    return Madhab.shafi;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerSettings &&
          runtimeType == other.runtimeType &&
          method == other.method &&
          madhab == other.madhab;

  @override
  int get hashCode => method.hashCode ^ madhab.hashCode;
}
