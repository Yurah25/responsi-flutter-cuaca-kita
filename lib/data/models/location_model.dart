class LocationModel {
  const LocationModel({
    this.id,
    required this.name,
    this.admin1,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.timezone,
  });

  final int? id;
  final String name;
  final String? admin1;
  final String country;
  final double latitude;
  final double longitude;
  final String? timezone;

  /// Kunci stabil untuk membandingkan lokasi favorit.
  String get storageKey {
    if (id != null) return 'id:$id';
    return '${name.toLowerCase()}_${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';
  }

  String get subtitle {
    final parts = <String>[
      if (admin1 != null && admin1!.trim().isNotEmpty) admin1!,
      if (country.trim().isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final latitude = json['latitude'];
    final longitude = json['longitude'];

    if (latitude is! num || longitude is! num) {
      throw const FormatException('Koordinat lokasi tidak tersedia.');
    }

    return LocationModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      name: (json['name'] ?? 'Lokasi tidak diketahui').toString(),
      admin1: json['admin1']?.toString(),
      country: (json['country'] ?? '').toString(),
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      timezone: json['timezone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'admin1': admin1,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
      };
}
