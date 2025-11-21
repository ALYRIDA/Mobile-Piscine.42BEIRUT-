class City {
  final String name;
  final String region;
  final String country;
  final double latitude;
  final double longitude;

  City({
    required this.name,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name']?.toString() ?? '',
      region: json['admin1']?.toString() ?? json['region']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      latitude: (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? json['lon'] ?? 0).toDouble(),
    );
  }
}