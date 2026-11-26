import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/weather_code_helper.dart';
import '../../../data/models/location_model.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/services/favorite_storage_service.dart';
import '../../../data/services/open_meteo_service.dart';
import '../../search/viewmodels/search_view_model.dart';
import '../../search/views/search_screen.dart';
import '../viewmodels/weather_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openSearch(BuildContext context) async {
    final weatherViewModel = context.read<WeatherViewModel>();
    final service = context.read<OpenMeteoService>();
    final storage = context.read<FavoriteStorageService>();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => ChangeNotifierProvider<SearchViewModel>(
          create: (_) => SearchViewModel(service, storage)..loadFavorites(),
          child: SearchScreen(
            onLocationSelected: (location) {
              weatherViewModel.loadWeather(location);
              Navigator.of(routeContext).pop();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.cloud_queue, color: Color(0xFF315FCE)),
            SizedBox(width: 10),
            Text(
              'CuacaKita',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cari kota',
            onPressed: () => _openSearch(context),
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<WeatherViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading && viewModel.weather == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.weather == null) {
            return _ErrorState(
              message: viewModel.errorMessage!,
              onRetry: viewModel.retry,
            );
          }

          final location = viewModel.selectedLocation;
          final weather = viewModel.weather;
          if (location == null || weather == null) {
            return _ErrorState(
              message: 'Data cuaca belum tersedia.',
              onRetry: viewModel.retry,
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.retry,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _LocationHeading(location: location),
                const SizedBox(height: 18),
                _CurrentWeatherCard(weather: weather),
                const SizedBox(height: 16),
                _WeatherDetails(weather: weather),
                const SizedBox(height: 24),
                _ForecastSection(forecasts: weather.daily),
                const SizedBox(height: 18),
                Text(
                  'Sumber data: Open-Meteo · Zona waktu: ${weather.timezone}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blueGrey.shade500,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LocationHeading extends StatelessWidget {
  const _LocationHeading({required this.location});
  final LocationModel location;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuaca saat ini',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.blueGrey.shade600,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          location.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF17243B),
                fontWeight: FontWeight.w800,
              ),
        ),
        if (location.subtitle.isNotEmpty)
          Text(
            location.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blueGrey.shade600,
                ),
          ),
      ],
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  const _CurrentWeatherCard({required this.weather});
  final WeatherData weather;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF477DE0), Color(0xFF274FAE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF315FCE).withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            WeatherCodeHelper.icon(current.weatherCode),
            size: 62,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            WeatherCodeHelper.description(current.weatherCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${current.temperature.toStringAsFixed(1)}${weather.temperatureUnit}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 54,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Terasa seperti ${current.apparentTemperature.toStringAsFixed(1)}${weather.temperatureUnit}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'Pembaruan: ${_formatApiTime(current.time)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherDetails extends StatelessWidget {
  const _WeatherDetails({required this.weather});
  final WeatherData weather;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.75,
      children: [
        _DetailCard(
          icon: Icons.water_drop_outlined,
          title: 'Kelembapan',
          value: '${current.relativeHumidity.toStringAsFixed(0)}%',
        ),
        _DetailCard(
          icon: Icons.air,
          title: 'Kecepatan angin',
          value: '${current.windSpeed.toStringAsFixed(1)} ${weather.windSpeedUnit}',
        ),
        _DetailCard(
          icon: Icons.grain,
          title: 'Curah hujan',
          value: '${current.precipitation.toStringAsFixed(1)} ${weather.precipitationUnit}',
        ),
        _DetailCard(
          icon: Icons.thermostat,
          title: 'Suhu terasa',
          value: '${current.apparentTemperature.toStringAsFixed(1)}${weather.temperatureUnit}',
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF315FCE), size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey.shade600,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17243B),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastSection extends StatelessWidget {
  const _ForecastSection({required this.forecasts});
  final List<DailyForecast> forecasts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prakiraan 7 Hari',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF17243B),
              ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Column(
            children: [
              for (var index = 0; index < forecasts.length; index++) ...[
                _ForecastRow(forecast: forecasts[index]),
                if (index != forecasts.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({required this.forecast});
  final DailyForecast forecast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              _weekday(forecast.date),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Icon(
            WeatherCodeHelper.icon(forecast.weatherCode),
            color: const Color(0xFF315FCE),
            size: 24,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '${forecast.precipitationProbabilityMax}% hujan',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey.shade600,
                  ),
            ),
          ),
          Text(
            '${forecast.temperatureMax.toStringAsFixed(0)}°',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 12),
          Text(
            '${forecast.temperatureMin.toStringAsFixed(0)}°',
            style: TextStyle(color: Colors.blueGrey.shade500),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.blueGrey),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

String _weekday(String date) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return date;
  const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  return names[parsed.weekday - 1];
}

String _formatApiTime(String value) {
  if (value.isEmpty) return '-';
  final parts = value.split('T');
  if (parts.length != 2) return value;
  return '${parts[1]} · ${parts[0]}';
}
