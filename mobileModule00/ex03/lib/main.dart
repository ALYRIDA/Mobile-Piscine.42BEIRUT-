import 'package:flutter/material.dart';

void main() {
  runApp(const Ex03App());
}

class Ex03App extends StatelessWidget {
  const Ex03App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorUI(),
    );
  }
}

class CalculatorUI extends StatefulWidget {
  const CalculatorUI({super.key});

  @override
  State<CalculatorUI> createState() => _CalculatorUIState();
}

class _CalculatorUIState extends State<CalculatorUI> with SingleTickerProviderStateMixin {
  String expression = '0';
  String result = '0';
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;
  bool _shouldResetExpression = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onButtonPressed(String value) {
    print('Button pressed: $value');
    
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      if (value == 'AC') {
        expression = '0';
        result = '0';
        _shouldResetExpression = false;
      } else if (value == 'C') {
        if (expression.length > 1) {
          expression = expression.substring(0, expression.length - 1);
        } else {
          expression = '0';
        }
        _shouldResetExpression = false;
      } else if (value == '=') {
        _calculateResult();
        _shouldResetExpression = true;
      } else {
        if (_shouldResetExpression) {
          expression = value;
          _shouldResetExpression = false;
        } else {
          if (expression == '0' && value != '.') {
            expression = value;
          } else {
            if (value == '.') {
              final parts = expression.split(RegExp(r'[\+\-\*\/]'));
              final lastNumber = parts.last;
              if (!lastNumber.contains('.')) {
                expression += value;
              }
            } else if (['+', '-', '*', '/'].contains(value)) {
              if (value == '-' && (expression == '0' || _isLastCharacterOperator(expression))) {
                expression += value;
              } else if (!_isLastCharacterOperator(expression)) {
                expression += value;
              } else if (_isLastCharacterOperator(expression) && value != '-') {
                expression = expression.substring(0, expression.length - 1) + value;
              }
            } else {
              expression += value;
            }
          }
        }
      }
    });
  }

  bool _isLastCharacterOperator(String expr) {
    if (expr.isEmpty) return false;
    final lastChar = expr[expr.length - 1];
    return ['+', '-', '*', '/'].contains(lastChar);
  }

  void _calculateResult() {
    try {
      if (expression.isEmpty || expression == '0') {
        result = '0';
        return;
      }

      final calculatedResult = _evaluateExpression(expression);
      result = calculatedResult;
    } catch (e) {
      print('Calculation error: $e');
      result = 'Error';
    }
  }

  String _evaluateExpression(String expr) {
    expr = expr.replaceAll(' ', '');
    
    // Handle simple number case
    if (double.tryParse(expr) != null) {
      return _formatResult(double.parse(expr));
    }

    try {
      // Use a simpler approach for evaluation
      return _simpleEvaluate(expr);
    } catch (e) {
      print('Evaluation error: $e');
      return 'Error';
    }
  }

  String _simpleEvaluate(String expr) {
    // Handle negative numbers at the beginning
    if (expr.startsWith('-')) {
      expr = '0$expr';
    }

    // Split by operators but keep them
    final List<String> tokens = [];
    String current = '';
    
    for (int i = 0; i < expr.length; i++) {
      final char = expr[i];
      
      if (['+', '-', '*', '/'].contains(char)) {
        if (current.isNotEmpty) {
          tokens.add(current);
          current = '';
        }
        tokens.add(char);
      } else {
        current += char;
      }
    }
    
    if (current.isNotEmpty) {
      tokens.add(current);
    }

    // First pass: handle multiplication and division
    for (int i = 1; i < tokens.length - 1; i++) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        final left = double.parse(tokens[i - 1]);
        final right = double.parse(tokens[i + 1]);
        double operationResult;
        
        if (tokens[i] == '*') {
          operationResult = left * right;
        } else {
          if (right == 0) {
            throw Exception('Division by zero');
          }
          operationResult = left / right;
        }
        
        // Replace the operation with result
        tokens.removeRange(i - 1, i + 2);
        tokens.insert(i - 1, operationResult.toString());
        i -= 2; // Adjust index after removal
      }
    }

    // Second pass: handle addition and subtraction
    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      final operator = tokens[i];
      final nextNumber = double.parse(tokens[i + 1]);
      
      if (operator == '+') {
        result += nextNumber;
      } else if (operator == '-') {
        result -= nextNumber;
      }
    }
    
    return _formatResult(result);
  }

  String _formatResult(double value) {
    if (value.isInfinite || value.isNaN) {
      return 'Error';
    }
    
    if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      String result = value.toStringAsFixed(6);
      result = result.replaceAll(RegExp(r'0*$'), '');
      if (result.endsWith('.')) {
        result = result.substring(0, result.length - 1);
      }
      return result;
    }
  }

  Widget _buildButton(String text, {bool isWide = false}) {
    const Color navyBlue = Color(0xFF0A2472);
    const Color babyBlue = Color(0xFF90E0EF);
    const Color accentBlue = Color(0xFF0077B6);

    Color buttonColor = babyBlue;
    Color textColor = navyBlue;

    if (text == '=') {
      buttonColor = accentBlue;
      textColor = Colors.white;
    } else if (text == 'AC') {
      buttonColor = const Color(0xFFE63946);
      textColor = Colors.white;
    } else if (text == 'C') {
      buttonColor = const Color(0xFFFB8500);
      textColor = Colors.white;
    } else if (['+', '-', '*', '/'].contains(text)) {
      buttonColor = const Color(0xFF003566);
      textColor = Colors.white;
    } else if (['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'].contains(text)) {
      buttonColor = babyBlue;
      textColor = navyBlue;
    }

    return Expanded(
      flex: isWide ? 2 : 1,
      child: Container(
        margin: EdgeInsets.all(_getButtonMargin()),
        child: AnimatedBuilder(
          animation: _buttonScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _buttonScaleAnimation.value,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(20),
                shadowColor: navyBlue.withOpacity(0.4),
                child: InkWell(
                  onTap: () => _onButtonPressed(text),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          buttonColor.withOpacity(0.9),
                          buttonColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFCAF0F8).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: navyBlue.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: _getButtonFontSize(),
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _getButtonMargin() {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    
    if (aspectRatio > 1.5) { // Very wide screens like Nest Hub
      return 3.0;
    } else if (screenSize.width > 800) {
      return 6.0;
    } else if (screenSize.width > 600) {
      return 5.0;
    }
    return 4.0;
  }

  double _getButtonFontSize() {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    
    if (aspectRatio > 1.5) { // Very wide screens like Nest Hub
      return 22.0;
    } else if (screenSize.width > 800) {
      return 28.0;
    } else if (screenSize.width > 600) {
      return 26.0;
    }
    return 24.0;
  }

  double _getExpressionFontSize() {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    
    if (aspectRatio > 1.5) { // Very wide screens like Nest Hub
      return 16.0;
    } else if (screenSize.width > 1000) {
      return 26.0;
    } else if (screenSize.width > 800) {
      return 24.0;
    } else if (screenSize.width > 650) {
      return 22.0;
    } else if (screenSize.width > 600) {
      return 20.0;
    }
    return 18.0;
  }

  double _getResultFontSize() {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    
    if (aspectRatio > 1.5) { // Very wide screens like Nest Hub
      return 20.0;
    } else if (screenSize.width > 1000) {
      return 32.0;
    } else if (screenSize.width > 800) {
      return 28.0;
    } else if (screenSize.width > 650) {
      return 26.0;
    } else if (screenSize.width > 600) {
      return 24.0;
    }
    return 22.0;
  }

  double _getDisplayPadding() {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    
    if (aspectRatio > 1.5) { // Very wide screens like Nest Hub
      return 12.0;
    } else if (screenSize.width > 800) {
      return 18.0;
    } else if (screenSize.width > 600) {
      return 16.0;
    }
    return 14.0;
  }

  double _getSectionPadding() {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    
    if (aspectRatio > 1.5) { // Very wide screens like Nest Hub
      return 12.0;
    } else if (screenSize.width > 800) {
      return 20.0;
    } else if (screenSize.width > 600) {
      return 18.0;
    }
    return 16.0;
  }

  double _getButtonSpacing() {
    final screenSize = MediaQuery.of(context).size;
    final aspectRatio = screenSize.width / screenSize.height;
    
    if (aspectRatio > 1.5) { // Very wide screens like Nest Hub
      return 6.0;
    } else if (screenSize.width > 800) {
      return 10.0;
    } else if (screenSize.width > 600) {
      return 9.0;
    }
    return 8.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    final isTablet = screenSize.width > 600;
    final aspectRatio = screenSize.width / screenSize.height;
    final isVeryWide = aspectRatio > 1.5; // Nest Hub has ~1.6 aspect ratio

    return Scaffold(
      appBar: isVeryWide ? null : AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calculate, 
              color: Colors.white,
              size: isTablet ? 28 : 26,
            ),
            SizedBox(width: isTablet ? 14 : 12),
            Text(
              'Calculator App',
              style: TextStyle(
                fontSize: isTablet ? 24 : 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0A2472),
        elevation: 12,
        shadowColor: Colors.blue.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(isTablet ? 22 : 20),
          ),
        ),
        toolbarHeight: isTablet ? 65 : 60,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A2472),
              Color(0xFF001D3D),
              Color(0xFF0A2472),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Display Section - HEIGHT RESPONSIVE
              if (isVeryWide) SizedBox(height: 16), // Extra space for very wide screens without app bar
              Expanded(
                flex: _getDisplayFlex(isPortrait, isVeryWide),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getSectionPadding(),
                    vertical: isVeryWide ? 8.0 : (isTablet ? 16.0 : 12.0),
                  ),
                  child: Column(
                    children: [
                      // Expression Display
                      Expanded(
                        flex: isVeryWide ? 2 : 3,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(_getDisplayPadding()),
                          decoration: BoxDecoration(
                            color: const Color(0xFF001D3D),
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                            border: Border.all(
                              color: const Color(0xFF0077B6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: isTablet ? 14 : 12,
                                spreadRadius: isTablet ? 2 : 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXPRESSION',
                                style: TextStyle(
                                  color: const Color(0xFF90E0EF),
                                  fontSize: isVeryWide ? 10 : (isTablet ? 12 : 10),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: isVeryWide ? 6 : (isTablet ? 10 : 6)),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    reverse: true,
                                    child: Text(
                                      expression,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: _getExpressionFontSize(),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'monospace',
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isVeryWide ? 8 : (isTablet ? 16 : 10)),
                      
                      // Result Display
                      Expanded(
                        flex: isVeryWide ? 3 : 4,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(_getDisplayPadding()),
                          decoration: BoxDecoration(
                            color: const Color(0xFF001D3D),
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                            border: Border.all(
                              color: result == 'Error' 
                                  ? const Color(0xFFE63946)
                                  : const Color(0xFF00B4D8),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: isTablet ? 14 : 12,
                                spreadRadius: isTablet ? 2 : 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RESULT',
                                style: TextStyle(
                                  color: const Color(0xFF90E0EF),
                                  fontSize: isVeryWide ? 10 : (isTablet ? 12 : 10),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: isVeryWide ? 6 : (isTablet ? 10 : 6)),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    reverse: true,
                                    child: Text(
                                      result,
                                      style: TextStyle(
                                        color: result == 'Error' 
                                            ? const Color(0xFFE63946)
                                            : Colors.white,
                                        fontSize: _getResultFontSize(),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Buttons Section - HEIGHT RESPONSIVE
              Expanded(
                flex: _getButtonsFlex(isPortrait, isVeryWide),
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: _getSectionPadding(),
                    vertical: isVeryWide ? 6.0 : (isTablet ? 10.0 : 8.0),
                  ),
                  child: Column(
                    children: [
                      // Row 1
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton('7'),
                            _buildButton('8'),
                            _buildButton('9'),
                            _buildButton('C'),
                          ],
                        ),
                      ),
                      SizedBox(height: _getButtonSpacing()),
                      
                      // Row 2
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton('4'),
                            _buildButton('5'),
                            _buildButton('6'),
                            _buildButton('/'),
                          ],
                        ),
                      ),
                      SizedBox(height: _getButtonSpacing()),
                      
                      // Row 3
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton('1'),
                            _buildButton('2'),
                            _buildButton('3'),
                            _buildButton('*'),
                          ],
                        ),
                      ),
                      SizedBox(height: _getButtonSpacing()),
                      
                      // Row 4
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton('.'),
                            _buildButton('0'),
                            _buildButton('='),
                            _buildButton('-'),
                          ],
                        ),
                      ),
                      SizedBox(height: _getButtonSpacing()),
                      
                      // Row 5
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton('AC', isWide: true),
                            _buildButton('+', isWide: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Status Indicator - CONDITIONAL FOR WIDE SCREENS
              if (!isVeryWide) // Hide status indicator on very wide screens to save space
                Padding(
                  padding: EdgeInsets.only(
                    bottom: isTablet ? 16.0 : 14.0,
                    top: isTablet ? 10.0 : 8.0,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20.0 : 18.0,
                      vertical: isTablet ? 10.0 : 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF001D3D),
                      borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
                      border: Border.all(
                        color: result == 'Error' 
                            ? const Color(0xFFE63946)
                            : const Color(0xFF0077B6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: isTablet ? 8 : 6,
                          spreadRadius: isTablet ? 1 : 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isTablet ? 10 : 8,
                          height: isTablet ? 10 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: result == 'Error' 
                                ? const Color(0xFFE63946)
                                : const Color(0xFF00B4D8),
                            boxShadow: [
                              BoxShadow(
                                color: (result == 'Error' 
                                    ? const Color(0xFFE63946)
                                    : const Color(0xFF00B4D8)).withOpacity(0.5),
                                blurRadius: isTablet ? 6 : 4,
                                spreadRadius: isTablet ? 1 : 1,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isTablet ? 10 : 8),
                        Text(
                          result == 'Error' ? 'Error' : 'Ready',
                          style: TextStyle(
                            color: result == 'Error' 
                                ? const Color(0xFFE63946)
                                : const Color(0xFF90E0EF),
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int _getDisplayFlex(bool isPortrait, bool isVeryWide) {
    if (isVeryWide) {
      return isPortrait ? 2 : 1;
    }
    return isPortrait ? (isTablet ? 2 : 2) : 1;
  }

  int _getButtonsFlex(bool isPortrait, bool isVeryWide) {
    if (isVeryWide) {
      return isPortrait ? 3 : 2;
    }
    return isPortrait ? (isTablet ? 3 : 3) : 2;
  }

  bool get isTablet {
    return MediaQuery.of(context).size.width > 600;
  }
}
