import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'env.dart';

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
  File? _capturedImage;
  List<File> _capturedImages = [];

  String? clientId;
  String? clientSCRT;
  String? tenantId;
  String? _operationsDriveId;

  @override
  void initState() {
    super.initState();
    _initializeEnvVariables();
    _requestCameraPermission();
  }

  void _initializeEnvVariables() {
    try {
      clientId = CLIENT_ID;
      clientSCRT = CLIENT_SCRT;
      tenantId = TENANT_ID;
    } catch (e) {
      print('Error accessing environment variables: $e');
    }
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      _initializeCamera();
    } else {
      print('Camera permission not granted');
    }
  }

  Future<void> _initializeCamera() async {
    try {
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
        print('No cameras available');
      }
    } catch (e) {
      print('Error initializing camera: $e');
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
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _uploadToOneDrive() async {
    final String? accessToken = await _getAccessToken();

    if (accessToken == null) {
      print('Failed to get access token');
      return;
    }

    await getAllDrives(accessToken);

    if (_operationsDriveId == null) {
      print('Drive named "Operations" not found');
      return;
    }

    for (File image in _capturedImages) {
      final String filePath = image.path;
      final String fileName = filePath.split('/').last;
      final String url =
          'https://graph.microsoft.com/v1.0/drives/$_operationsDriveId/items/root:/Pictures/$fileName:/content';

      final List<int> fileBytes = await image.readAsBytes();

      try {
        final http.Response response = await http.put(
          Uri.parse(url),
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
      } catch (e) {
        print('Error uploading file: $e');
      }
    }
  }

  Future<String?> _getAccessToken() async {
    final String url =
        'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';

    final Map<String, String> body = {
      'client_id': clientId ?? '',
      'scope': 'https://graph.microsoft.com/.default',
      'client_secret': clientSCRT ?? '',
      'grant_type': 'client_credentials',
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Access token: ${response.body}');
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['access_token'];
      } else {
        print('Failed to get access token: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  Future<void> getAllDrives(String accessToken) async {
    final String url = 'https://graph.microsoft.com/v1.0/drives';

    try {
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> drives = responseData['value'];

        if (drives.isEmpty) {
          print('No drives found.');
          return;
        }

        print('All Drives:');
        drives.forEach((drive) {
          print('Drive Name: ${drive['name']}');
        });

        // Find the drive with the name "Documents"
        final drive = drives.firstWhere(
          (drive) => drive['name'] == 'Documents',
          orElse: () => null,
        );

        if (drive != null) {
          setState(() {
            _operationsDriveId = drive['id'] as String?;
          });
          print('Found Documents Drive ID: $_operationsDriveId');
        } else {
          print('Drive named "Documents" not found.');
        }
      } else {
        print('Failed to get drives: ${response.body}');
      }
    } catch (e) {
      print('Error getting drives: $e');
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
        actions: [
          if (_capturedImages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PhotoShowcase(
                      images: _capturedImages,
                      onUpload: _uploadToOneDrive,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: _isCameraInitialized
          ? _capturedImage == null
              ? CameraPreview(_cameraController)
              : Column(
                  children: [
                    Expanded(child: Image.file(_capturedImage!)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _capturedImage = null;
                            });
                          },
                          child: Text('Retake'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_capturedImage != null) {
                                _capturedImages.add(_capturedImage!);
                                _capturedImage = null;
                              }
                            });
                          },
                          child: Text('Use Photo'),
                        ),
                      ],
                    ),
                  ],
                )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        tooltip: 'Take a Photo',
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

class PhotoShowcase extends StatelessWidget {
  final List<File> images;
  final Future<void> Function() onUpload;

  const PhotoShowcase({Key? key, required this.images, required this.onUpload})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Showcase'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Image.file(images[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onUpload,
        tooltip: 'Upload to OneDrive',
        child: Icon(Icons.cloud_upload),
      ),
    );
  }
}
