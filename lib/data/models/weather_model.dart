class CurrentWeather {
  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  final String time;
  final double temperature;
  final double relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: (json['time'] ?? '').toString(),
      temperature: _asDouble(json['temperature_2m']),
      relativeHumidity: _asDouble(json['relative_humidity_2m']),
      apparentTemperature: _asDouble(json['apparent_temperature']),
      precipitation: _asDouble(json['precipitation']),
      weatherCode: _asInt(json['weather_code']),
      windSpeed: _asDouble(json['wind_speed_10m']),
    );
  }
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
  });

  final String date;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbabilityMax;
  final int weatherCode;

  factory DailyForecast.fromValues({
    required String date,
    required dynamic temperatureMax,
    required dynamic temperatureMin,
    required dynamic precipitationProbabilityMax,
    required dynamic weatherCode,
  }) {
    return DailyForecast(
      date: date,
      temperatureMax: _asDouble(temperatureMax),
      temperatureMin: _asDouble(temperatureMin),
      precipitationProbabilityMax: _asInt(precipitationProbabilityMax),
      weatherCode: _asInt(weatherCode),
    );
  }
}

class WeatherData {
  const WeatherData({
    required this.current,
    required this.daily,
    required this.timezone,
    required this.temperatureUnit,
    required this.windSpeedUnit,
    required this.precipitationUnit,
  });

  final CurrentWeather current;
  final List<DailyForecast> daily;
  final String timezone;
  final String temperatureUnit;
  final String windSpeedUnit;
  final String precipitationUnit;

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'];
    final dailyJson = json['daily'];

    if (currentJson is! Map<String, dynamic> ||
        dailyJson is! Map<String, dynamic>) {
      throw const FormatException('Format respons cuaca dari API tidak sesuai.');
    }

    final dates = dailyJson['time'];
    final maxTemps = dailyJson['temperature_2m_max'];
    final minTemps = dailyJson['temperature_2m_min'];
    final rainProbabilities = dailyJson['precipitation_probability_max'];
    final weatherCodes = dailyJson['weather_code'];

    if (dates is! List ||
        maxTemps is! List ||
        minTemps is! List ||
        rainProbabilities is! List ||
        weatherCodes is! List) {
      throw const FormatException('Data prakiraan harian tidak lengkap.');
    }

    var length = dates.length;
    if (maxTemps.length < length) length = maxTemps.length;
    if (minTemps.length < length) length = minTemps.length;
    if (rainProbabilities.length < length) length = rainProbabilities.length;
    if (weatherCodes.length < length) length = weatherCodes.length;

    final forecasts = <DailyForecast>[];
    for (var index = 0; index < length; index++) {
      forecasts.add(
        DailyForecast.fromValues(
          date: dates[index].toString(),
          temperatureMax: maxTemps[index],
          temperatureMin: minTemps[index],
          precipitationProbabilityMax: rainProbabilities[index],
          weatherCode: weatherCodes[index],
        ),
      );
    }

    final currentUnits = json['current_units'];

    return WeatherData(
      current: CurrentWeather.fromJson(currentJson),
      daily: forecasts,
      timezone: (json['timezone'] ?? 'auto').toString(),
      temperatureUnit: currentUnits is Map<String, dynamic>
          ? (currentUnits['temperature_2m'] ?? '°C').toString()
          : '°C',
      windSpeedUnit: currentUnits is Map<String, dynamic>
          ? (currentUnits['wind_speed_10m'] ?? 'km/h').toString()
          : 'km/h',
      precipitationUnit: currentUnits is Map<String, dynamic>
          ? (currentUnits['precipitation'] ?? 'mm').toString()
          : 'mm',
    );
  }
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _asInt(dynamic value) {
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
