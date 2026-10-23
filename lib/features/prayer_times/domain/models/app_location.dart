class AppLocation {
  final String name;
  final double latitude;
  final double longitude;
  final bool isAuto;

  const AppLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isAuto = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'isAuto': isAuto,
      };

  factory AppLocation.fromJson(Map<String, dynamic> json) => AppLocation(
        name: json['name'] as String? ?? 'القاهرة',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 30.0444,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 31.2357,
        isAuto: json['isAuto'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLocation &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          isAuto == other.isAuto;

  @override
  int get hashCode =>
      name.hashCode ^ latitude.hashCode ^ longitude.hashCode ^ isAuto.hashCode;

  @override
  String toString() =>
      'AppLocation(name: $name, lat: $latitude, lng: $longitude, isAuto: $isAuto)';
}
