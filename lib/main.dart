import 'package:flutter/material.dart';

//import 'main_screen.dart';
//import 'register_screen.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF145DA0);
    final primarySwatch = MaterialColor(
      primaryColor.value,
      <int, Color>{
        50: primaryColor.withOpacity(0.1),
        100: primaryColor.withOpacity(0.2),
        200: primaryColor.withOpacity(0.3),
        300: primaryColor.withOpacity(0.4),
        400: primaryColor.withOpacity(0.5),
        500: primaryColor.withOpacity(0.6),
        600: primaryColor.withOpacity(0.7),
        700: primaryColor.withOpacity(0.8),
        800: primaryColor.withOpacity(0.9),
        900: primaryColor.withOpacity(1),
      },
    );

    return MaterialApp(
      title: 'RevIA',
      theme: ThemeData(
        primarySwatch: primarySwatch,
      ),
      home: const Scaffold(
          backgroundColor: primaryColor,
          body:
              LoginScreen() //MainScreen(token: "tokenteste") //token:"tokenteste"
          ),
    );
  }
}
