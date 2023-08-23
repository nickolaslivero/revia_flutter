import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  final String token;

  const MainScreen({Key? key, required this.token}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  String? _imagePath;
  String? _resultText;
  String? _percentText;

  void _addImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });

      _resultText = null;
      _percentText = null;
    }
  }

  Future<Map<String, dynamic>> _sendImageForVerification(
      String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);
      final response = await http.post(
        Uri.parse('http://18.228.213.252:8000/api/process-image/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'base64_image': base64Image,
        }),
      );
      //print('Response status code: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> prediction = responseData['prediction'];
        final double fakeProbability = prediction['fake'] * 100;
        final double realProbability = prediction['real'] * 100;

        String resultText = '';
        double probability = 0;

        if (fakeProbability > realProbability) {
          resultText = 'Artificial';
          probability = fakeProbability;
        } else {
          resultText = 'Real';
          probability = realProbability;
        }

        return {
          'resultText': resultText,
          'percentText': '${probability.toStringAsFixed(2)}%',
        };
      } else {
        return {
          'resultText': 'Error',
          'percentText': '0%',
        };
      }
    } catch (e) {
      rethrow;
    }
  }

  void _verifyImage() async {
    if (_imagePath != null) {
      final result = await _sendImageForVerification(_imagePath!);

      setState(() {
        _resultText = result['resultText'];
        _percentText = result['percentText'];
      });
    } else {
      _showDialog('Error', 'Por favor, adicione uma imagem primeiro.');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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

  Widget _buildImageWidget() {
    return Column(
      children: [
        _buildImage(),
        const SizedBox(height: 10),
        if (_resultText != null && _percentText != null) _buildResultWidget(),
      ],
    );
  }

  Widget _buildImage() {
    if (_imagePath != null) {
      return kIsWeb
          ? Image.network(
              _imagePath!,
              fit: BoxFit.scaleDown,
              width: 450,
              height: 450,
            )
          : Image.file(
              File(_imagePath!),
              fit: BoxFit.scaleDown,
              width: 450,
              height: 450,
            );
    } else {
      return const SizedBox.shrink();
    }
  }

  bool _showLoading = true;

  Widget _buildResultWidget() {
    if (_showLoading) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _showLoading = false;
        });
      });
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10),
        ],
      );
    } else if (_resultText != null && _percentText != null) {
      return Column(
        children: [
          Text(
            _resultText!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            _percentText!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _navigateToLoginScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _navigateToLoginScreen,
            ),
            Center(
              child: Image.asset(
                'assets/revia_logo.png',
                width: 90,
                height: 90,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _addImage,
                    child: const Text('Adicionar'),
                  ),
                  Container(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: _verifyImage,
                    child: const Text('Verificar'),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: _buildImageWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
