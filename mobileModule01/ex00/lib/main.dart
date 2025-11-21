import 'package:flutter/material.dart';

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
      home: const AnimatedWeatherHomePage(),
    );
  }
}

class AnimatedWeatherHomePage extends StatefulWidget {
  const AnimatedWeatherHomePage({super.key});

  @override
  State<AnimatedWeatherHomePage> createState() => _AnimatedWeatherHomePageState();
}

class _AnimatedWeatherHomePageState extends State<AnimatedWeatherHomePage> 
    with SingleTickerProviderStateMixin, TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pageAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
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
              child: Icon(
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
            
            // Animated divider
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