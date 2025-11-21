import 'package:flutter/material.dart';
import '../models/weather.dart';

class WeatherTabs extends StatelessWidget {
  final TabController tabController;
  final String currentCity;
  final String coordinates;
  final bool isGeolocation;
  final WeatherData? currentWeather;
  final List<WeatherData> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final bool isLoading;
  final bool locationPermissionGranted;

  const WeatherTabs({
    super.key,
    required this.tabController,
    required this.currentCity,
    required this.coordinates,
    required this.isGeolocation,
    required this.currentWeather,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.isLoading,
    required this.locationPermissionGranted,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        _buildCurrentlyTab(context),
        _buildTodayTab(context),
        _buildWeeklyTab(context),
      ],
    );
  }

  Widget _buildCurrentlyTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(currentCity, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if (coordinates.isNotEmpty) Text(coordinates, style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 30),
          if (isLoading) const Center(child: CircularProgressIndicator())
          else if (currentWeather != null) _buildCurrentWeather()
          else Expanded(child: _buildEmptyState('Search for a city or use your location to see current weather')),
          if (!locationPermissionGranted && currentWeather == null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: _buildPermissionMessage(),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather() {
    final w = currentWeather!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(w.weatherEmoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          Text('${w.temperature.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(w.weatherCondition, style: const TextStyle(fontSize: 20, color: Colors.white70)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherMetric('Humidity', '${w.humidity.round()}%', Icons.water_drop),
              _buildWeatherMetric('Wind', '${w.windSpeed.toStringAsFixed(1)} km/h', Icons.air),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today\'s Forecast', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (isLoading) const Center(child: CircularProgressIndicator())
          else if (hourlyForecast.isNotEmpty) Expanded(child: _buildHourlyForecast())
          else Expanded(child: _buildEmptyState('Search for a city to see today\'s forecast')),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return ListView.builder(
      itemCount: hourlyForecast.length,
      itemBuilder: (context, i) {
        final w = hourlyForecast[i];
        final hour = (DateTime.now().hour + i) % 24;
        final time = '${hour.toString().padLeft(2, '0')}:00';
        return ListTile(
          leading: Text(time, style: const TextStyle(color: Colors.white)),
          title: Text(w.weatherEmoji),
          trailing: Text('${w.temperature.toStringAsFixed(1)}°C', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildWeeklyTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('7-Day Forecast', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (isLoading) const Center(child: CircularProgressIndicator())
          else if (dailyForecast.isNotEmpty) Expanded(child: _buildDailyForecast())
          else Expanded(child: _buildEmptyState('Search for a city to see weekly forecast')),
        ],
      ),
    );
  }

  Widget _buildDailyForecast() {
    return ListView.builder(
      itemCount: dailyForecast.length,
      itemBuilder: (context, i) {
        final f = dailyForecast[i];
        final dayName = _weekdayShort(f.date.weekday);
        return ListTile(
          leading: Text(dayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          title: Text(f.weatherEmoji),
          trailing: Text('${f.maxTemp.toStringAsFixed(1)}° / ${f.minTemp.toStringAsFixed(1)}°', style: const TextStyle(color: Colors.white)),
        );
      },
    );
  }

  String _weekdayShort(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1) % 7];
  }

  Widget _buildWeatherMetric(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 30),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 60, color: Colors.white54),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildPermissionMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange),
      ),
      child: const Center(
        child: Text('Location access not granted\nYou can search for cities manually', textAlign: TextAlign.center, style: TextStyle(color: Colors.orange)),
      ),
    );
  }
}