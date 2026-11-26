import 'package:flutter/foundation.dart';

import '../../../data/models/location_model.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/services/open_meteo_service.dart';

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._service);

  final OpenMeteoService _service;

  LocationModel? selectedLocation;
  WeatherData? weather;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadInitialWeather() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Lokasi awal juga dicari melalui Geocoding API, bukan koordinat cuaca statis.
      final locations = await _service.searchCities('Purwokerto');
      if (locations.isEmpty) {
        throw Exception('Lokasi awal tidak ditemukan. Coba cari kota lain.');
      }
      selectedLocation = locations.first;
      weather = await _service.fetchWeather(locations.first);
    } catch (error) {
      errorMessage = _readableError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeather(LocationModel location) async {
    selectedLocation = location;
    weather = null;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      weather = await _service.fetchWeather(location);
    } catch (error) {
      errorMessage = _readableError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    final location = selectedLocation;
    if (location == null) {
      await loadInitialWeather();
    } else {
      await loadWeather(location);
    }
  }

  String _readableError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.contains('SocketException') || message.contains('Failed host lookup')) {
      return 'Tidak dapat terhubung ke internet. Periksa koneksi lalu coba lagi.';
    }
    if (message.contains('TimeoutException')) {
      return 'Permintaan terlalu lama. Silakan coba lagi.';
    }
    return message;
  }
}
