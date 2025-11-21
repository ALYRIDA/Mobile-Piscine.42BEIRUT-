import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
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
    with SingleTickerProviderStateMixin, TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pageAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _displayText = '';
  bool _isGeolocation = false;
  String _coordinatesText = '';
  bool _locationPermissionGranted = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Trigger animation when tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageAnimationController.forward(from: 0.0);
      }
    });

    // Start initial animation
    _pageAnimationController.forward();
    
    // Check location permission status on startup
    _checkLocationPermission();
  }

  // Check if location permission is granted
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationPermissionGranted = false;
      });
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    setState(() {
      _locationPermissionGranted = permission == LocationPermission.always || 
                                  permission == LocationPermission.whileInUse;
    });
  }

  // Request location permission and get coordinates
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDisabledDialog();
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permission denied
          _showPermissionDeniedMessage();
          setState(() {
            _locationPermissionGranted = false;
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission permanently denied
        _showPermissionPermanentlyDeniedMessage();
        setState(() {
          _locationPermissionGranted = false;
          _isLoadingLocation = false;
        });
        return;
      }

      // Permission granted - get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      setState(() {
        _locationPermissionGranted = true;
        _coordinatesText = 'Lat: ${position.latitude.toStringAsFixed(4)}\n'
                          'Lng: ${position.longitude.toStringAsFixed(4)}';
        _displayText = 'Current Location';
        _isGeolocation = true;
        _isLoadingLocation = false;
      });

    } catch (e) {
      setState(() {
        _coordinatesText = 'Error getting location';
        _isLoadingLocation = false;
      });
    }
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text('Please enable location services to use geolocation feature.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location permission denied. You can still search for cities manually.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showPermissionPermanentlyDeniedMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text('Location permission is permanently denied. '
              'Please enable it in app settings to use geolocation feature. '
              'You can still search for cities manually.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _displayText = value.trim();
        _isGeolocation = false;
        _coordinatesText = '';
      });
    }
  }

  void _onGeolocationPressed() {
    _getCurrentLocation();
  }

  void _onClearSearch() {
    setState(() {
      _searchController.clear();
      _displayText = '';
      _isGeolocation = false;
      _coordinatesText = '';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildSearchField(),
        actions: [
          _buildGeolocationButton(),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEnhancedTabContent('Currently', Icons.wb_sunny, Colors.blueAccent),
          _buildEnhancedTabContent('Today', Icons.today, Colors.greenAccent),
          _buildEnhancedTabContent('Weekly', Icons.calendar_today, Colors.purpleAccent),
        ],
      ),
      bottomNavigationBar: _buildAnimatedBottomAppBar(),
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search city...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
                  onPressed: _onClearSearch,
                )
              : null,
        ),
        style: const TextStyle(color: Colors.white),
        onSubmitted: _onSearchSubmitted,
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildGeolocationButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(
              Icons.my_location, 
              color: _isGeolocation ? Colors.blueAccent : Colors.white.withOpacity(0.7),
              size: 28,
            ),
            onPressed: _onGeolocationPressed,
            tooltip: 'Use current location',
          ),
          if (!_locationPermissionGranted)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTabContent(String title, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _pageAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0.0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon Container
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: _isLoadingLocation
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Icon(
                      icon,
                      size: 70,
                      color: Colors.white,
                    ),
            ),
            
            const SizedBox(height: 40),
            
            // Title with gradient text
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ).createShader(bounds);
              },
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Display search text, geolocation, or coordinates
            if (_isLoadingLocation)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Getting location...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              )
            else if (_coordinatesText.isNotEmpty)
              Column(
                children: [
                  Text(
                    '📍',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _displayText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _coordinatesText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else if (_displayText.isNotEmpty)
              Column(
                children: [
                  Text(
                    _isGeolocation ? '📍' : '🔍',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isGeolocation ? Colors.greenAccent : Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _displayText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _isGeolocation ? Colors.greenAccent : Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.5)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Permission status message
            if (!_locationPermissionGranted && _displayText.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  'Location access not granted\nYou can search for cities manually',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              // Subtle description text
              Text(
                _getTabDescription(title),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  String _getTabDescription(String title) {
    switch (title) {
      case 'Currently':
        return 'Real-time weather conditions and current temperature';
      case 'Today':
        return 'Hourly forecast and today\'s weather overview';
      case 'Weekly':
        return '7-day forecast with detailed weather predictions';
      default:
        return '';
    }
  }

  Widget _buildAnimatedBottomAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(8),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.4),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.wb_sunny),
              text: 'Currently',
            ),
            Tab(
              icon: Icon(Icons.today),
              text: 'Today',
            ),
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Weekly',
            ),
          ],
        ),
      ),
    );
  }
}