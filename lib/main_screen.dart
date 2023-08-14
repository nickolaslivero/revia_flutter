import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hooks/flutter_hooks.dart';
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

  void _addImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });

      // Chamar a função de verificação após adicionar a imagem
      await _verifyImage(_imagePath!);
    }
  }

  Future<void> _verifyImage(String imagePath) async {
    final response = await _sendImageForVerification(imagePath);

    if (response.statusCode == 200) {
      _showDialog('Success', 'Image verification successful.');
    } else {
      _showDialog('Error',
          'Image verification failed. Status code: ${response.statusCode}');
    }
  }

  Future<http.Response> _sendImageForVerification(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('http://18.228.213.252:8000/api/process-image/'),
        body: {'image': base64Image},
      );

      return response;
    } catch (e) {
      throw e;
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
        );
      },
    );
  }

  Widget _buildImageWidget() {
    if (_imagePath != null) {
      if (kIsWeb) {
        return Image.network(_imagePath!);
      } else {
        return Image.file(File(_imagePath!));
      }
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
        title: const Text('RevIA'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(20),
              ),
              ElevatedButton(
                onPressed: _addImage,
                child: const Text('Add Image'),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: _buildImageWidget(),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_imagePath != null) {
                    _verifyImage(_imagePath!);
                  } else {
                    _showDialog('Error', 'Please add an image first.');
                  }
                },
                child: const Text('Verify Image'),
              ),
              Container(
                  margin: const EdgeInsets.all(20), child: Text(widget.token)),
              TextButton(
                onPressed: _navigateToLoginScreen,
                child: const Text('Deslogar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
