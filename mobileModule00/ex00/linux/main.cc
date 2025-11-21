import 'package:flutter/material.dart';

void main() {
  runApp(const Ex00App());
}

class Ex00App extends StatelessWidget {
  const Ex00App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ex00',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomeHomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A  simple text',
                style: TextStyle(fontSize: screenWidth * 0.06),
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed: () {
                  print('Button pressed');
                },
                child: Text(
                  'Press me',
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
