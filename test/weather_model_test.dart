import 'package:flutter_test/flutter_test.dart';
import 'package:cuaca_kita/core/weather_code_helper.dart';
import 'package:cuaca_kita/data/models/location_model.dart';
import 'package:cuaca_kita/data/models/weather_model.dart';

void main() {
  group('LocationModel', () {
    test('membaca data lokasi dari JSON Geocoding API', () {
      final location = LocationModel.fromJson({
        'id': 123,
        'name': 'Makassar',
        'admin1': 'Sulawesi Selatan',
        'country': 'Indonesia',
        'latitude': -5.14,
        'longitude': 119.42,
        'timezone': 'Asia/Makassar',
      });

      expect(location.name, 'Makassar');
      expect(location.country, 'Indonesia');
      expect(location.latitude, -5.14);
      expect(location.storageKey, 'id:123');
    });

    test('menghasilkan FormatException bila koordinat tidak tersedia', () {
      expect(
        () => LocationModel.fromJson({'name': 'Kota tanpa koordinat'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('WeatherData', () {
    test('membaca data current dan prakiraan harian dari JSON API', () {
      final weather = WeatherData.fromJson({
        'timezone': 'Asia/Jakarta',
        'current': {
          'time': '2026-11-26T07:00',
          'temperature_2m': 29.2,
          'relative_humidity_2m': 78,
          'apparent_temperature': 32.1,
          'precipitation': 0.2,
          'weather_code': 2,
          'wind_speed_10m': 8.5,
        },
        'current_units': {
          'temperature_2m': '°C',
          'wind_speed_10m': 'km/h',
          'precipitation': 'mm',
        },
        'daily': {
          'time': ['2026-11-26'],
          'temperature_2m_max': [31.0],
          'temperature_2m_min': [24.0],
          'precipitation_probability_max': [40],
          'weather_code': [61],
        },
      });

      expect(weather.current.temperature, 29.2);
      expect(weather.current.relativeHumidity, 78);
      expect(weather.daily, hasLength(1));
      expect(weather.daily.first.temperatureMax, 31.0);
      expect(weather.daily.first.precipitationProbabilityMax, 40);
      expect(weather.timezone, 'Asia/Jakarta');
    });
  });

  group('WeatherCodeHelper', () {
    test('mengubah weather code menjadi deskripsi bahasa Indonesia', () {
      expect(WeatherCodeHelper.description(0), 'Cerah');
      expect(WeatherCodeHelper.description(3), 'Mendung');
      expect(WeatherCodeHelper.description(61), 'Hujan');
      expect(WeatherCodeHelper.description(95), 'Badai petir');
    });
  });
}
