import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _imagePath;

  void _addImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });

      final File imageFile = File(_imagePath!);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);
      print("base64 image: \n");
      print(base64Image);
    }
  }


  void _verifyImage() async {
    if (_imagePath != null) {
      final File imageFile = File(_imagePath!);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      showDialog(
        context: context,
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
        context: context,
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
              ElevatedButton(
                onPressed: _addImage,
                child: const Text('Add Image'),
              ),
              ElevatedButton(
                onPressed: _verifyImage,
                child: const Text('Verify Image'),
              ),
              if (_imagePath != null)
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Image.file(File(_imagePath!)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
