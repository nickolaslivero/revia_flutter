import 'package:flutter/material.dart';

import 'main_screen.dart';
import 'register_screen.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'RevIA',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home:
            const LoginScreen() // const RegistrationScreen() // const MainScreen(),
        );
  }
}
