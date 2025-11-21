class WeatherData {
  final double temperature;
  final String weatherCode;
  final double humidity;
  final double windSpeed;

  WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
  });

  // Small helpers for display (very naive mapping)
  String get weatherEmoji {
    final code = int.tryParse(weatherCode) ?? 0;
    if (code >= 80) return '🌧️';
    if (code >= 60) return '⛈️';
    if (code >= 50) return '🌦️';
    if (code >= 30) return '☁️';
    return '☀️';
  }

  String get weatherCondition {
    final code = int.tryParse(weatherCode) ?? 0;
    if (code >= 80) return 'Heavy rain';
    if (code >= 60) return 'Rain';
    if (code >= 50) return 'Drizzle';
    if (code >= 30) return 'Cloudy';
    return 'Sunny';
  }
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String weatherCode;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });

  String get weatherEmoji {
    final code = int.tryParse(weatherCode) ?? 0;
    if (code >= 80) return '🌧️';
    if (code >= 60) return '🌦️';
    if (code >= 30) return '☁️';
    return '☀️';
  }
}
