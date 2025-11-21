import 'package:flutter/material.dart';

void main() {
  runApp(const Ex01App());
}

class Ex01App extends StatelessWidget {
  const Ex01App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise 01',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      home: const Ex01HomePage(),
    );
  }
}

class Ex01HomePage extends StatefulWidget {
  const Ex01HomePage({super.key});

  @override
  State<Ex01HomePage> createState() => _Ex01HomePageState();
}

class _Ex01HomePageState extends State<Ex01HomePage>
    with SingleTickerProviderStateMixin {
  bool isaareslanweb = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleText() {
    if (isaareslanweb) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isaareslanweb = !isaareslanweb;
    });
    print('Press Here');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black87,
              Colors.grey.shade900,
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Text Display - Fixed overlapping issue
                SizedBox(
                  height: 150,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: isaareslanweb
                        ? _buildHelloWorldText()
                        : _buildWelcomeText(),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Toggle Button
                ElevatedButton(
                  onPressed: toggleText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.grey.withOpacity(0.3),
                    elevation: 12,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.shade800,
                          Colors.black,
                          Colors.grey.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade600,
                        width: 1,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 24,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedRotation(
                            turns: isaareslanweb ? 0.5 : 0,
                            duration: const Duration(milliseconds: 500),
                            child: const Icon(
                              Icons.swap_vert,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Toggle Text',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isaareslanweb ? Colors.green : Colors.blue,
                          boxShadow: [
                            BoxShadow(
                              color: isaareslanweb
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.blue.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'State: ${isaareslanweb ? 'Hello World!' : 'Welcome'}',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return KeyedSubtree(
      key: const ValueKey('welcome'),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Colors.grey.shade400,
            Colors.white,
            Colors.grey.shade300,
          ],
        ).createShader(bounds),
        child: const Text(
          'Welcome to my world',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHelloWorldText() {
    return KeyedSubtree(
      key: const ValueKey('hello'),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.white,
            Colors.grey.shade400,
          ],
        ).createShader(bounds),
        child: const Text(
          'Hello World!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}