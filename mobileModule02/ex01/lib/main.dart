import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'models/city.dart';
import 'models/weather.dart';
import 'models/country.dart';
import 'widgets/search_field.dart';
import 'widgets/suggestion_overlay.dart';
import 'widgets/weather_tabs.dart';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // Controllers and Focus
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchFieldKey = GlobalKey();
  Timer? _debounceTimer;

  // State
  String _currentCity = 'Search for a city';
  String _coordinates = '';
  bool _isGeolocation = false;
  bool _locationPermissionGranted = false;

  // Weather data
  WeatherData? _currentWeather;
  List<WeatherData> _hourlyForecast = [];
  List<DailyForecast> _dailyForecast = [];
  bool _isLoadingWeather = false;

  // Search suggestions
  List<City> _citySuggestions = [];
  List<Country> _countrySuggestions = [];
  bool _isLoadingCities = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _checkLocationPermission();

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _showSuggestionsOverlay();
      }
    });
  }

  // ---------------- Search ----------------
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _clearSuggestions();
    } else {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _searchCities(query);
        _searchCountries(query);
      });
    }
  }

  void _clearSuggestions() {
    _removeOverlay();
    setState(() {
      _citySuggestions = [];
      _countrySuggestions = [];
    });
  }

  Future<void> _searchCities(String query) async {
    if (query.length < 2) {
      setState(() => _citySuggestions = []);
      return;
    }

    setState(() => _isLoadingCities = true);
    try {
      final response = await http.get(Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List?;
        setState(() {
          _citySuggestions = results?.map((c) => City.fromJson(c)).toList() ?? [];
          _isLoadingCities = false;
        });
        if (_overlayEntry != null) _showSuggestionsOverlay();
      }
    } catch (e) {
      debugPrint('Error searching cities: $e');
      setState(() => _isLoadingCities = false);
    }
  }

  Future<void> _searchCountries(String query) async {
    if (query.isEmpty) {
      setState(() => _countrySuggestions = []);
      return;
    }

    try {
      final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final filteredCountries = data.where((country) {
          final name = country['name']?['common']?.toString().toLowerCase() ?? '';
          return name.startsWith(query.toLowerCase());
        }).take(3).map((c) => Country.fromJson(c)).toList();

        setState(() => _countrySuggestions = filteredCountries);
        if (_overlayEntry != null) _showSuggestionsOverlay();
      }
    } catch (e) {
      debugPrint('Error searching countries: $e');
      setState(() => _countrySuggestions = []);
    }
  }

  void _showSuggestionsOverlay() {
    _removeOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchCtx = _searchFieldKey.currentContext;
      if (searchCtx == null) return;

      final renderBox = searchCtx.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
      final maxHeight = (screenHeight - offset.dy - size.height - 16).clamp(100.0, 400.0);

      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 8,
          width: size.width,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: SuggestionOverlay(
                citySuggestions: _citySuggestions,
                countrySuggestions: _countrySuggestions,
                isLoading: _isLoadingCities,
                onCitySelected: _onCitySelected,
                onCountrySelected: _onCountrySelected,
                width: size.width,
                searchQuery: _searchController.text.trim(),
              ),
            ),
          ),
        ),
      );

      Overlay.of(context)?.insert(_overlayEntry!);
    });
  }

  void _removeOverlay() {
    try {
      _overlayEntry?.remove();
    } catch (_) {}
    _overlayEntry = null;
  }

  void _onCitySelected(City city) {
    setState(() {
      _currentCity = '${city.name}, ${city.region}, ${city.country}';
      _coordinates = 'Lat: ${city.latitude.toStringAsFixed(4)}, Lng: ${city.longitude.toStringAsFixed(4)}';
      _isGeolocation = false;
    });
    _fetchWeatherData(city.latitude, city.longitude);
    _clearSearch();
  }

  void _onCountrySelected(Country country) {
    setState(() {
      _currentCity = country.name;
      _coordinates = '${country.flag} ${country.name}';
      _isGeolocation = false;
    });

    // Remove the overlay and clear the search
    _removeOverlay();
    _searchController.clear();
    _searchFocusNode.unfocus();

    // Fetch weather for the first major city in the country
    _fetchWeatherForCountry(country.name);
  }


  void _clearSearch() {
    _searchController.clear();
    _removeOverlay();
    _searchFocusNode.unfocus();
  }

  // ---------------- Weather Fetching ----------------
  Future<void> _fetchWeatherForCountry(String countryName) async {
    setState(() => _isLoadingWeather = true);
    try {
      final response = await http.get(Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$countryName&count=1&format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          final city = City.fromJson(results[0]);
          await _fetchWeatherData(city.latitude, city.longitude);
          setState(() {
            _currentCity = '${city.name}, ${city.country}';
            _coordinates = 'Lat: ${city.latitude.toStringAsFixed(4)}, Lng: ${city.longitude.toStringAsFixed(4)}';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching weather for country: $e');
    } finally {
      setState(() => _isLoadingWeather = false);
    }
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    setState(() => _isLoadingWeather = true);
    try {
      final response = await http.get(Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Current weather
        final current = data['current'];
        _currentWeather = WeatherData(
          temperature: (current['temperature_2m'] ?? 0.0).toDouble(),
          weatherCode: current['weather_code']?.toString() ?? '0',
          humidity: (current['relative_humidity_2m'] ?? 0.0).toDouble(),
          windSpeed: (current['wind_speed_10m'] ?? 0.0).toDouble(),
        );

        // Hourly forecast
        final hourly = data['hourly'];
        _hourlyForecast = List.generate(
          (hourly['temperature_2m'] as List).length.clamp(0, 24),
          (i) => WeatherData(
            temperature: (hourly['temperature_2m'][i] ?? 0.0).toDouble(),
            weatherCode: hourly['weather_code'][i]?.toString() ?? '0',
            humidity: 0.0,
            windSpeed: 0.0,
          ),
        );

        // Daily forecast
        final daily = data['daily'];
        _dailyForecast = List.generate(
          (daily['time'] as List).length.clamp(0, 7),
          (i) => DailyForecast(
            date: DateTime.parse(daily['time'][i]),
            maxTemp: (daily['temperature_2m_max'][i] ?? 0.0).toDouble(),
            minTemp: (daily['temperature_2m_min'][i] ?? 0.0).toDouble(),
            weatherCode: daily['weather_code'][i]?.toString() ?? '0',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
    } finally {
      setState(() => _isLoadingWeather = false);
    }
  }

  // ---------------- Location ----------------
  Future<void> _checkLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();

    setState(() {
      _locationPermissionGranted = serviceEnabled &&
          (permission == LocationPermission.always || permission == LocationPermission.whileInUse);
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingWeather = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showLocationServiceDisabledDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedMessage();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionPermanentlyDeniedMessage();
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentCity = 'Current Location';
        _coordinates =
            'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        _isGeolocation = true;
      });
      await _fetchWeatherData(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() => _isLoadingWeather = false);
    }
  }

  void _showLocationServiceDisabledDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text('Please enable location services to use geolocation.'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );

  void _showPermissionDeniedMessage() => ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Location permission denied. You can still search manually.')));

  void _showPermissionPermanentlyDeniedMessage() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text('Location permission is permanently denied. Please enable it in app settings.'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );

  // ---------------- UI ----------------
  Widget _buildGeolocationButton() {
    return IconButton(
      icon: Icon(Icons.my_location, color: _isGeolocation ? Colors.blue : Colors.white),
      onPressed: _getCurrentLocation,
      tooltip: 'Use current location',
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchField(
          key: _searchFieldKey,
          controller: _searchController,
          onSubmitted: (value) => _onCitySelected(City(name: value, country: '', region: '', latitude: 0, longitude: 0)),
          onClear: _clearSearch,
          onTap: _showSuggestionsOverlay,
          focusNode: _searchFocusNode,
        ),
        actions: [_buildGeolocationButton()],
      ),
      body: WeatherTabs(
        tabController: _tabController,
        currentCity: _currentCity,
        coordinates: _coordinates,
        isGeolocation: _isGeolocation,
        currentWeather: _currentWeather,
        hourlyForecast: _hourlyForecast,
        dailyForecast: _dailyForecast,
        isLoading: _isLoadingWeather,
        locationPermissionGranted: _locationPermissionGranted,
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.wb_sunny), text: 'Currently'),
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Weekly'),
          ],
        ),
      ),
    );
  }
}
