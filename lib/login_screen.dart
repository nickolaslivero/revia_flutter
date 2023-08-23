import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;

import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<bool> serverStatus() async {
    try {
      final response =
          await http.head(Uri.parse('http://18.228.213.252:8000/api/docs'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> internetStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool isServerOnline = await serverStatus();
    bool isConnectedToInternet = await internetStatus();

    if (!isConnectedToInternet) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro de Conexão'),
            content: const Text('Você não está conectado à internet.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (!isServerOnline) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro de Conexão'),
            content: const Text('O servidor não está disponível.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String url = 'http://18.228.213.252:8000/api/users/login/';

    Map<String, String> data = {
      "username": _usernameController.text,
      "password": _passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String token = responseData['token'];
        _navigateToMainScreen(token);
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Erro de Login'),
              content: const Text('Senha incorreta ou usuário não existe.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      print(response.statusCode);
      print(response.body);
    } catch (e) {
      // Handle request error
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erro de Login'),
            content: const Text('Ocorreu um erro ao tentar fazer login.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToMainScreen(String token) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(token: token)),
    );
  }

  void _navigateToRegisterScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF145DA0),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/revia_logo.png'),
                const SizedBox(height: 20.0),
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nome de usuário',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.black),
                  // Change text color
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // White background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0),
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Senha',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.black),
                  // Change text color
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white, // White background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    _navigateToRegisterScreen();
                  },
                  child: const Text(
                    'Não possui uma conta? Cadastre',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
