class PredefinedCity {
  final String englishName;
  final String arabicName;
  final double latitude;
  final double longitude;

  const PredefinedCity({
    required this.englishName,
    required this.arabicName,
    required this.latitude,
    required this.longitude,
  });
}

const List<PredefinedCity> kPredefinedCities = [
  PredefinedCity(
    englishName: 'Cairo',
    arabicName: 'القاهرة',
    latitude: 30.0444,
    longitude: 31.2357,
  ),
  PredefinedCity(
    englishName: 'Alexandria',
    arabicName: 'الإسكندرية',
    latitude: 31.2001,
    longitude: 29.9187,
  ),
  PredefinedCity(
    englishName: 'Giza',
    arabicName: 'الجيزة',
    latitude: 30.0131,
    longitude: 31.2089,
  ),
  PredefinedCity(
    englishName: 'Mansoura',
    arabicName: 'المنصورة',
    latitude: 31.0409,
    longitude: 31.3785,
  ),
  PredefinedCity(
    englishName: 'Tanta',
    arabicName: 'طنطا',
    latitude: 30.7865,
    longitude: 31.0004,
  ),
  PredefinedCity(
    englishName: 'Asyut',
    arabicName: 'أسيوط',
    latitude: 27.1783,
    longitude: 31.1859,
  ),
  PredefinedCity(
    englishName: 'Riyadh',
    arabicName: 'الرياض',
    latitude: 24.7136,
    longitude: 46.6753,
  ),
  PredefinedCity(
    englishName: 'Jeddah',
    arabicName: 'جدة',
    latitude: 21.4858,
    longitude: 39.1925,
  ),
  PredefinedCity(
    englishName: 'Makkah',
    arabicName: 'مكة المكرمة',
    latitude: 21.3891,
    longitude: 39.8579,
  ),
  PredefinedCity(
    englishName: 'Madinah',
    arabicName: 'المدينة المنورة',
    latitude: 24.5247,
    longitude: 39.5692,
  ),
  PredefinedCity(
    englishName: 'Dubai',
    arabicName: 'دبي',
    latitude: 25.2048,
    longitude: 55.2708,
  ),
  PredefinedCity(
    englishName: 'Kuwait',
    arabicName: 'الكويت',
    latitude: 29.3759,
    longitude: 47.9774,
  ),
  PredefinedCity(
    englishName: 'Doha',
    arabicName: 'الدوحة',
    latitude: 25.2854,
    longitude: 51.5310,
  ),
  PredefinedCity(
    englishName: 'Amman',
    arabicName: 'عمان',
    latitude: 31.9454,
    longitude: 35.9284,
  ),
];
