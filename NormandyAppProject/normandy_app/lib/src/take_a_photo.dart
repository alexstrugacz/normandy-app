import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: 'assets/.env');
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
  final ImagePicker _picker = ImagePicker();
  List<String> _productNames = [];
  List<String> _prices = [];
  List<bool> _selectedNames = [];
  List<bool> _selectedPrices = [];
  List<String> _finalProductNames = [];
  List<String> _finalPrices = [];
  File? _capturedImage;

  final String clientId = dotenv.env['CLIENT_ID'] ?? '';
  final String clientSecret = dotenv.env['CLIENT_SECRET'] ?? '';
  final String tenantId = dotenv.env['TENANT_ID'] ?? '';
  String? _operationsDriveId;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      _initializeCamera();
    } else {
      // Handle the case when the permission is not granted
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
    }
  }

  Future<void> _takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }

    try {
      final XFile? imageFile = await _cameraController.takePicture();

      if (imageFile == null) {
        throw Exception('Error: Image file is null');
      }

      setState(() {
        _capturedImage = File(imageFile.path);
      });

      await _processImage(File(imageFile.path));
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _processImage(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    try {
      final RecognizedText recognisedText =
          await textRecognizer.processImage(inputImage);

      List<String> productNames = [];
      List<String> prices = [];

      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          String lineText = line.text.trim();

          if (_isPrice(lineText)) {
            prices.add(lineText);
          } else {
            productNames.add(lineText);
          }
        }
      }

      setState(() {
        _productNames = productNames;
        _prices = prices;
        _selectedNames = List<bool>.filled(productNames.length, false);
        _selectedPrices = List<bool>.filled(prices.length, false);
      });
    } catch (e) {
      print('Error recognizing text: $e');
    } finally {
      textRecognizer.close();
    }
  }

  bool _isPrice(String input) {
    return RegExp(r'^\$?\d+(\.\d{1,2})?$').hasMatch(input);
  }

  void _submitSelections() {
    List<String> finalProductNames = [];
    List<String> finalPrices = [];

    for (int i = 0; i < _productNames.length; i++) {
      if (_selectedNames[i]) {
        finalProductNames.add(_productNames[i]);
      }
    }

    for (int i = 0; i < _prices.length; i++) {
      if (_selectedPrices[i]) {
        finalPrices.add(_prices[i]);
      }
    }

    setState(() {
      _finalProductNames = finalProductNames;
      _finalPrices = finalPrices;
    });

    _showSubmissionDialog();
  }

  void _showSubmissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Receipt Items and Final Price submitted'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_finalProductNames.isNotEmpty)
                Text(
                  'Final Product Names:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              if (_finalProductNames.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      _finalProductNames.map((name) => Text(name)).toList(),
                ),
              SizedBox(height: 10),
              if (_finalPrices.isNotEmpty)
                Text(
                  'Final Prices:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              if (_finalPrices.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _finalPrices.map((price) => Text(price)).toList(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _getAccessToken() async {
    final String url =
        'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';

    final Map<String, String> body = {
      'client_id': clientId,
      'scope': 'https://graph.microsoft.com/.default',
      'client_secret': clientSecret,
      'grant_type': 'client_credentials',
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['access_token'];
    } else {
      print('Failed to get access token: ${response.body}');
      return null;
    }
  }

  Future<void> getAllDrives(String accessToken) async {
    final String url = 'https://graph.microsoft.com/v1.0/drives';

    final http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> drives = responseData['value'];

      print('Drives: $drives');

      setState(() {
        _operationsDriveId = drives.firstWhere(
          (drive) => drive['name'] == 'Documents',
          orElse: () => {},
        )['id'] as String?;
      });

      print('Found Operations Drive ID: $_operationsDriveId');
    } else {
      print('Failed to get drives: ${response.body}');
    }
  }

  Future<void> _uploadToOneDrive() async {
    if (_capturedImage == null) return;

    final String? accessToken = await _getAccessToken();

    if (accessToken == null) {
      print('Failed to get access token');
      return;
    }

    if (_operationsDriveId == null) {
      print('Drive named "Operations" not found');
      return;
    }

    final String filePath = _capturedImage!.path;
    final String fileName = filePath.split('/').last;
    final List<int> fileBytes = await _capturedImage!.readAsBytes();

    final String uploadUrl =
        "https://graph.microsoft.com/v1.0/drives/$_operationsDriveId/root:/$fileName:/content";

    final http.Response response = await http.put(
      Uri.parse(uploadUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/octet-stream',
      },
      body: fileBytes,
    );

    if (response.statusCode == 201) {
      print('File uploaded successfully');
    } else {
      print('File upload failed: ${response.body}');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.header),
      ),
      body: _isCameraInitialized
          ? Column(
              children: [
                Expanded(child: CameraPreview(_cameraController)),
                ElevatedButton(
                  onPressed: _takePicture,
                  child: Text('Take Photo'),
                ),
                if (_productNames.isNotEmpty || _prices.isNotEmpty)
                  Expanded(
                    child: ListView(
                      children: [
                        ..._productNames.asMap().entries.map((entry) {
                          int index = entry.key;
                          String name = entry.value;
                          return CheckboxListTile(
                            title: Text('Product Name: $name'),
                            value: _selectedNames[index],
                            onChanged: (value) {
                              setState(() {
                                _selectedNames[index] = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                        ..._prices.asMap().entries.map((entry) {
                          int index = entry.key;
                          String price = entry.value;
                          return CheckboxListTile(
                            title: Text('Price: $price'),
                            value: _selectedPrices[index],
                            onChanged: (value) {
                              setState(() {
                                _selectedPrices[index] = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                if (_productNames.isNotEmpty || _prices.isNotEmpty)
                  ElevatedButton(
                    onPressed: _submitSelections,
                    child: Text('Submit'),
                  ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String? accessToken = await _getAccessToken();
          if (accessToken != null) {
            await getAllDrives(accessToken);
            await _uploadToOneDrive();
          }
        },
        tooltip: 'Connect to OneDrive',
        child: Icon(Icons.cloud_upload),
      ),
    );
  }
}
