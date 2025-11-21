import 'package:flutter/material.dart';

void main() {
  runApp(const Ex00App());
}

class Ex00App extends StatelessWidget {
  const Ex00App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise 00',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      home: const Ex00HomePage(),
    );
  }
}

class Ex00HomePage extends StatelessWidget {
  const Ex00HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final isSmallScreen = screenWidth < 635;
          final isVerySmallScreen = screenWidth < 400;

          return Container(
            width: double.infinity,
            height: double.infinity,
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
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Responsive Text
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.grey.shade400,
                          Colors.white,
                          Colors.grey.shade300,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: isVerySmallScreen
                              ? 32.0
                              : isSmallScreen
                                  ? 40.0
                                  : 64.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 24.0 : 40.0),
                    
                    // Responsive Button
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: isSmallScreen ? 280.0 : 400.0,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          print('Button pressed');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 32.0 : 48.0,
                            vertical: isSmallScreen ? 16.0 : 20.0,
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.grey.withOpacity(0.3),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
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
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade600,
                              width: 1,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 32.0 : 48.0,
                              vertical: isSmallScreen ? 16.0 : 20.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.flash_on,
                                  color: Colors.white,
                                  size: isSmallScreen ? 20.0 : 24.0,
                                ),
                                SizedBox(width: isSmallScreen ? 8.0 : 12.0),
                                Text(
                                  'Press Me',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16.0 : 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}