class Weather {
  final double temperature;
  final double temperatureMax;
  final double temperatureMin;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final double precipitation;
  final DateTime time;

  // Previsioni per i prossimi giorni
  final List<DailyForecast>? dailyForecasts;

  Weather({
    required this.temperature,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.precipitation,
    required this.time,
    this.dailyForecasts,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>?;

    List<DailyForecast>? forecasts;
    if (daily != null) {
      final times = daily['time'] as List<dynamic>;
      final tempMaxList = daily['temperature_2m_max'] as List<dynamic>;
      final tempMinList = daily['temperature_2m_min'] as List<dynamic>;
      final weatherCodes = daily['weather_code'] as List<dynamic>;
      final precipitationSum = daily['precipitation_sum'] as List<dynamic>;

      forecasts = List.generate(
        times.length > 7 ? 7 : times.length,
        (index) => DailyForecast(
          date: DateTime.parse(times[index] as String),
          temperatureMax: (tempMaxList[index] as num).toDouble(),
          temperatureMin: (tempMinList[index] as num).toDouble(),
          weatherCode: weatherCodes[index] as int,
          precipitationSum: (precipitationSum[index] as num).toDouble(),
        ),
      );
    }

    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      temperatureMax: (current['temperature_2m'] as num).toDouble(),
      temperatureMin: (current['temperature_2m'] as num).toDouble(),
      weatherCode: current['weather_code'] as int,
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      humidity: current['relative_humidity_2m'] as int,
      precipitation: (current['precipitation'] as num).toDouble(),
      time: DateTime.parse(current['time'] as String),
      dailyForecasts: forecasts,
    );
  }

  String get weatherDescriptionKey {
    // WMO Weather interpretation codes - returns a key for localization
    switch (weatherCode) {
      case 0:
        return 'clear';
      case 1:
        return 'mostlyClear';
      case 2:
        return 'partlyCloudy';
      case 3:
        return 'cloudy';
      case 45:
      case 48:
        return 'fog';
      case 51:
      case 53:
      case 55:
        return 'drizzle';
      case 61:
        return 'lightRain';
      case 63:
        return 'moderateRain';
      case 65:
        return 'heavyRain';
      case 71:
        return 'lightSnow';
      case 73:
        return 'moderateSnow';
      case 75:
        return 'heavySnow';
      case 77:
        return 'snowGrains';
      case 80:
      case 81:
      case 82:
        return 'showers';
      case 85:
      case 86:
        return 'snowShowers';
      case 95:
        return 'thunderstorm';
      case 96:
      case 99:
        return 'thunderstormHail';
      default:
        return 'weatherNotAvailable';
    }
  }

  String get weatherIcon {
    switch (weatherCode) {
      case 0:
        return '☀️';
      case 1:
      case 2:
        return '🌤️';
      case 3:
        return '☁️';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return '🌧️';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return '❄️';
      case 95:
      case 96:
      case 99:
        return '⛈️';
      default:
        return '🌡️';
    }
  }
}

class DailyForecast {
  final DateTime date;
  final double temperatureMax;
  final double temperatureMin;
  final int weatherCode;
  final double precipitationSum;

  DailyForecast({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.weatherCode,
    required this.precipitationSum,
  });

  String get weatherIcon {
    switch (weatherCode) {
      case 0:
        return '☀️';
      case 1:
      case 2:
        return '🌤️';
      case 3:
        return '☁️';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return '🌧️';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return '❄️';
      case 95:
      case 96:
      case 99:
        return '⛈️';
      default:
        return '🌡️';
    }
  }

  String get weatherDescriptionKey {
    // WMO Weather interpretation codes - returns a key for localization
    switch (weatherCode) {
      case 0:
        return 'clear';
      case 1:
        return 'mostlyClear';
      case 2:
        return 'partlyCloudy';
      case 3:
        return 'cloudy';
      case 45:
      case 48:
        return 'fog';
      case 51:
      case 53:
      case 55:
        return 'drizzle';
      case 61:
        return 'lightRain';
      case 63:
        return 'moderateRain';
      case 65:
        return 'heavyRain';
      case 71:
        return 'lightSnow';
      case 73:
        return 'moderateSnow';
      case 75:
        return 'heavySnow';
      case 77:
        return 'snowGrains';
      case 80:
      case 81:
      case 82:
        return 'showers';
      case 85:
      case 86:
        return 'snowShowers';
      case 95:
        return 'thunderstorm';
      case 96:
      case 99:
        return 'thunderstormHail';
      default:
        return 'weatherNotAvailable';
    }
  }
}
