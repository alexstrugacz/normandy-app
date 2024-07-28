import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ML Text Recognition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TakeAPhoto(header: 'Take a Photo'),
    );
  }
}

class TakeAPhoto extends StatefulWidget {
  final String header;

  const TakeAPhoto({Key? key, required this.header}) : super(key: key);

  @override
  _TakeAPhotoState createState() => _TakeAPhotoState();
}

class _TakeAPhotoState extends State<TakeAPhoto> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isPictureTaken = false;
  File? _capturedImage;
  SharedPreferences? _prefs;
  String? _email;
  String? _password;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _email = _prefs?.getString("email");
    _password = _prefs?.getString("password");
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      _initializeCamera();
    } else {
      print('Camera permission not granted.');
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _cameraController = CameraController(
        _cameras[0],
        ResolutionPreset.high,
      );

      await _cameraController.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } else {
      print('No cameras available.');
    }
  }

  Future<void> _takePicture() async {
    if (!_cameraController.value.isInitialized) {
      print('Error: Camera is not initialized.');
      return;
    }

    try {
      final XFile file = await _cameraController.takePicture();
      setState(() {
        _capturedImage = File(file.path);
        _isPictureTaken = true;
        _cameraController.dispose(); // Freeze the camera preview
      });
      _processImage(_capturedImage!);
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _processImage(File image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    setState(() {
      // _productNames.clear();
      // _prices.clear();
    });

    // for (TextBlock block in recognizedText.blocks) {
    //   for (TextLine line in block.lines) {
    //     final text = line.text;
    //     if (text.contains('\$')) {
    //       _prices.add(text);
    //     } else {
    //       _productNames.add(text);
    //     }
    //   }
    // }

    // setState(() {
    //   _selectedNames = List.generate(_productNames.length, (_) => false);
    //   _selectedPrices = List.generate(_prices.length, (_) => false);
    // });

    textRecognizer.close();
  }

  Future<String?> _generateJwt() async {
    if (_email == null || _password == null) {
      print('Email or password is null.');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('https://normandy-backend.azurewebsites.net/api/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _email!,
          'password': _password!,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['token'];
      } else {
        print('Failed to generate JWT. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error generating JWT: $e');
      return null;
    }
  }

  Future<void> _uploadImage() async {
    if (_capturedImage == null) {
      print('No image captured.');
      return;
    }

    final jwt = await _generateJwt();
    if (jwt == null) {
      print('Failed to generate JWT.');
      return;
    }

    final imageBytes = await _capturedImage!.readAsBytes();
    final apiUrl =
        'https://graph.microsoft.com/v1.0/me/drive/root:/Pictures/${DateTime.now().millisecondsSinceEpoch}.jpg:/content';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'image/jpeg',
        },
        body: imageBytes,
      );

      if (response.statusCode == 201) {
        print('Image uploaded successfully.');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.header),
      ),
      body: Column(
        children: [
          if (_isCameraInitialized)
            Container(
              height: MediaQuery.of(context).size.height *
                  0.6, // Camera takes up 60% of the height
              child: _isPictureTaken
                  ? Image.file(
                      _capturedImage!) // Show captured image instead of camera preview
                  : CameraPreview(_cameraController),
            ),
          if (!_isPictureTaken)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: _takePicture,
                child: const Text('Take Picture'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (_isPictureTaken)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: _uploadImage,
                child: const Text('Upload to OneDrive'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
