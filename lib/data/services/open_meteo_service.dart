import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';

class OpenMeteoService {
  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);

  /// Mencari nama kota melalui Open-Meteo Geocoding API.
  Future<List<LocationModel>> searchCities(String query) async {
    final keyword = query.trim();
    if (keyword.length < 2) return [];

    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': keyword,
        'count': '10',
        'language': 'id',
        'format': 'json',
      },
    );

    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Pencarian lokasi gagal (HTTP ${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Respons pencarian lokasi tidak valid.');
    }

    final results = decoded['results'];
    if (results == null) return [];
    if (results is! List) {
      throw const FormatException('Daftar hasil lokasi tidak valid.');
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map(LocationModel.fromJson)
        .toList();
  }

  /// Mengambil cuaca aktual dan prakiraan 7 hari dari koordinat lokasi.
  Future<WeatherData> fetchWeather(LocationModel location) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': location.latitude.toStringAsFixed(6),
        'longitude': location.longitude.toStringAsFixed(6),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Pengambilan cuaca gagal (HTTP ${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Respons cuaca tidak valid.');
    }

    return WeatherData.fromJson(decoded);
  }

  void close() => _client.close();
}
