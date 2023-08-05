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

  const MainScreen({super.key, required this.token});

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
    }
  }

  void _verifyImage() async {
    if (_imagePath != null) {
      final File imageFile = File(_imagePath!);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final currentContext = useContext();
      showDialog(
        context: currentContext,
        builder: (_) {
          return FutureBuilder<bool>(
            future: _sendImageForVerification(base64Image),
            builder: (_, AsyncSnapshot<bool> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AlertDialog(
                  title: Text('Verifying Image'),
                  content: Text('Image verification in progress...'),
                );
              } else if (snapshot.hasData && snapshot.data!) {
                return const AlertDialog(
                  title: Text('Success'),
                  content: Text('Image verification successful.'),
                );
              } else {
                return const AlertDialog(
                  title: Text('Error'),
                  content: Text('Image verification failed.'),
                );
              }
            },
          );
        },
      );
    } else {
      showDialog(
        context: useContext(),
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Error'),
            content: Text('Please add an image first.'),
          );
        },
      );
    }
  }

  Future<bool> _sendImageForVerification(String base64Image) async {
    final response = await http.post(
      Uri.parse('https://exemplo.com/upload'),
      // Substitua pelo URL correto da sua API
      body: {'image': base64Image},
    );

    return response.statusCode == 200;
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
                onPressed: _verifyImage,
                child: const Text('Verify Image'),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: Text(widget.token)
              ),
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
