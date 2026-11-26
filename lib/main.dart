import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/services/favorite_storage_service.dart';
import 'data/services/open_meteo_service.dart';
import 'features/home/viewmodels/weather_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        Provider<OpenMeteoService>(create: (_) => OpenMeteoService()),
        Provider<FavoriteStorageService>(
          create: (_) => FavoriteStorageService(),
        ),
        ChangeNotifierProvider<WeatherViewModel>(
          create: (context) => WeatherViewModel(
            context.read<OpenMeteoService>(),
          )..loadInitialWeather(),
        ),
      ],
      child: const CuacaKitaApp(),
    ),
  );
}
