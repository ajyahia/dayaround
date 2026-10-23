import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jimy/features/prayer_times/data/cities_data.dart';
import 'package:jimy/features/prayer_times/domain/models/app_location.dart';

class LocationService {
  static const String _keyName = 'location_name';
  static const String _keyLat = 'location_latitude';
  static const String _keyLng = 'location_longitude';
  static const String _keyAuto = 'location_is_auto';

  static const AppLocation defaultLocation = AppLocation(
    name: 'القاهرة',
    latitude: 30.0444,
    longitude: 31.2357,
    isAuto: false,
  );

  final SharedPreferences? _prefs;

  LocationService([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  Future<AppLocation> getCachedLocation() async {
    final prefs = await _getPrefs();
    final name = prefs.getString(_keyName);
    final lat = prefs.getDouble(_keyLat);
    final lng = prefs.getDouble(_keyLng);
    final isAuto = prefs.getBool(_keyAuto) ?? false;

    if (name != null && lat != null && lng != null) {
      return AppLocation(
        name: name,
        latitude: lat,
        longitude: lng,
        isAuto: isAuto,
      );
    }
    return defaultLocation;
  }

  Future<void> cacheLocation(AppLocation location) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyName, location.name);
    await prefs.setDouble(_keyLat, location.latitude);
    await prefs.setDouble(_keyLng, location.longitude);
    await prefs.setBool(_keyAuto, location.isAuto);
  }

  Future<AppLocation?> requestAutoLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 8),
        ),
      );

      // Check if location matches a known city within 30km
      String cityName = 'موقعي الحالي';
      for (final city in kPredefinedCities) {
        final dist = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          city.latitude,
          city.longitude,
        );
        if (dist <= 30000) {
          cityName = city.arabicName;
          break;
        }
      }

      final location = AppLocation(
        name: cityName,
        latitude: position.latitude,
        longitude: position.longitude,
        isAuto: true,
      );

      await cacheLocation(location);
      return location;
    } catch (e) {
      debugPrint('Geolocator error: $e');
      return null;
    }
  }
}
