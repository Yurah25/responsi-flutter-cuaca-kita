import 'package:flutter/foundation.dart';

import '../../../data/models/location_model.dart';
import '../../../data/services/favorite_storage_service.dart';
import '../../../data/services/open_meteo_service.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this._service, this._storageService);

  final OpenMeteoService _service;
  final FavoriteStorageService _storageService;

  List<LocationModel> searchResults = [];
  List<LocationModel> favorites = [];
  bool isLoading = false;
  bool hasSearched = false;
  String? errorMessage;

  Future<void> loadFavorites() async {
    try {
      favorites = await _storageService.loadFavorites();
      notifyListeners();
    } catch (_) {
      errorMessage = 'Lokasi favorit belum dapat dimuat.';
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    final keyword = query.trim();
    if (keyword.length < 2) {
      searchResults = [];
      hasSearched = false;
      errorMessage = 'Masukkan minimal 2 karakter nama kota.';
      notifyListeners();
      return;
    }

    isLoading = true;
    hasSearched = true;
    errorMessage = null;
    searchResults = [];
    notifyListeners();

    try {
      searchResults = await _service.searchCities(keyword);
      if (searchResults.isEmpty) {
        errorMessage = 'Kota tidak ditemukan. Periksa ejaan atau coba nama lain.';
      }
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(LocationModel location) {
    return favorites.any((item) => item.storageKey == location.storageKey);
  }

  Future<void> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      favorites.removeWhere((item) => item.storageKey == location.storageKey);
    } else {
      favorites.add(location);
    }

    // Perbarui tampilan langsung, kemudian simpan daftar terbaru ke perangkat.
    notifyListeners();
    try {
      await _storageService.saveFavorites(favorites);
    } catch (_) {
      errorMessage = 'Perubahan favorit gagal disimpan. Coba lagi.';
      notifyListeners();
    }
  }
}
