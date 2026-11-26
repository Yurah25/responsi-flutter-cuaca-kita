import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

class FavoriteStorageService {
  static const String _storageKey = 'cuaca_kita_favorite_locations';
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  Future<List<LocationModel>> loadFavorites() async {
    final savedItems = await _preferences.getStringList(_storageKey) ?? [];
    final favorites = <LocationModel>[];

    for (final savedItem in savedItems) {
      try {
        final decoded = jsonDecode(savedItem);
        if (decoded is Map<String, dynamic>) {
          favorites.add(LocationModel.fromJson(decoded));
        }
      } on FormatException {
        // Lewati data lama/rusak agar item lain tetap bisa dibaca.
      }
    }

    return favorites;
  }

  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final encodedItems = favorites
        .map((location) => jsonEncode(location.toJson()))
        .toList();
    await _preferences.setStringList(_storageKey, encodedItems);
  }
}
