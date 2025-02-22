import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'env.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  const TakeAPhoto({super.key, required this.header});

  @override
  TakeAPhotoState createState() => TakeAPhotoState();
}

class TakeAPhotoState extends State<TakeAPhoto> {
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
      if(kDebugMode) print('Error accessing environment variables: $e');
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
      if(kDebugMode) print('Camera permission not granted');
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
        if(kDebugMode) print('No cameras available');
      }
    } catch (e) {
      if(kDebugMode) print('Error initializing camera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }

    try {
      final XFile imageFile = await _cameraController.takePicture();

      if (imageFile.path.isEmpty) {
        throw Exception('Error: Image file is null');
      }

      setState(() {
        _capturedImage = File(imageFile.path);
      });
    } catch (e) {
      if(kDebugMode) print('Error taking picture: $e');
    }
  }

  Future<void> _uploadToOneDrive(String folderName) async {
    final String? accessToken = await _getAccessToken();

    if (accessToken == null) {
      if(kDebugMode) print('Failed to get access token');
      return;
    }

    await getAllDrives(accessToken);

    if (_operationsDriveId == null) {
      if(kDebugMode) print('Drive named "Operations" not found');
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString("email");

    if (email == null) {
      if(kDebugMode) print('No email found in SharedPreferences');
      return;
    }

    final String userName = email.split('@').first;
    final String date = DateFormat('MMyy').format(DateTime.now());
    final String folderPath = 'nbexp_${userName}_$date-$folderName';

    for (int i = 0; i < _capturedImages.length; i++) {
      final File image = _capturedImages[i];
      final String fileName = '${(i + 1).toString().padLeft(4, '0')}.jpg';
      final String url =
          'https://graph.microsoft.com/v1.0/drives/$_operationsDriveId/items/root:/Expenses/$folderPath/$fileName:/content';

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
          if(kDebugMode) print('File uploaded successfully: $fileName');
          _showUploadSuccessDialog();
        } else {
          if(kDebugMode) print('File upload failed: ${response.body}');
        }
      } catch (e) {
        if(kDebugMode) print('Error uploading file: $e');
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
        if(kDebugMode) print('Access token: ${response.body}');
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['access_token'];
      } else {
        if(kDebugMode) print('Failed to get access token: ${response.body}');
        return null;
      }
    } catch (e) {
      if(kDebugMode) print('Error getting access token: $e');
      return null;
    }
  }

  Future<void> getAllDrives(String accessToken) async {
    final String sitesUrl = 'https://graph.microsoft.com/v1.0/sites';

    try {
      final http.Response sitesResponse = await http.get(
        Uri.parse(sitesUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (sitesResponse.statusCode == 200) {
        final Map<String, dynamic> sitesData = json.decode(sitesResponse.body);
        final List<dynamic> sites = sitesData['value'];

        if (sites.isEmpty) {
          if(kDebugMode) print('No sites found.');
          return;
        }

        final site = sites.firstWhere(
          (site) => site['name'] == 'Operations',
          orElse: () => null,
        );

        if (site != null) {
          final String operationsSiteId = site['id'];
          if(kDebugMode) print('Found Operations Site ID: $operationsSiteId');

          final String drivesUrl =
              'https://graph.microsoft.com/v1.0/sites/$operationsSiteId/drives';
          final http.Response drivesResponse = await http.get(
            Uri.parse(drivesUrl),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          );

          if (drivesResponse.statusCode == 200) {
            final Map<String, dynamic> drivesData =
                json.decode(drivesResponse.body);
            final List<dynamic> drives = drivesData['value'];

            if (drives.isEmpty) {
              if(kDebugMode) print('No drives found for Operations site.');
              return;
            }

            final drive = drives.firstWhere(
              (drive) => drive['name'] == 'Documents',
              orElse: () => null,
            );

            if (drive != null) {
              setState(() {
                _operationsDriveId = drive['id'] as String?;
              });
              if(kDebugMode) print('Found Documents Drive ID: $_operationsDriveId');
            } else {
              if(kDebugMode) print('Drive named "Documents" not found.');
            }
          } else {
            if(kDebugMode) print('Failed to get drives: ${drivesResponse.body}');
          }
        } else {
          if(kDebugMode) print('Site named "Operations" not found.');
        }
      } else {
        if(kDebugMode) print('Failed to get sites: ${sitesResponse.body}');
      }
    } catch (e) {
      if(kDebugMode) print('Error getting sites or drives: $e');
    }
  }

  void _showUploadSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Successful'),
          content: Text('All images have been uploaded successfully.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToShowcase() async {
    final updatedImages = await Navigator.of(context).push<List<File>>(
      MaterialPageRoute(
        builder: (context) => PhotoShowcase(
          images: List<File>.from(_capturedImages),
          onUpload: (folderName) => _uploadToOneDrive(folderName),
        ),
      ),
    );

    if (updatedImages != null) {
      setState(() {
        _capturedImages = updatedImages;
      });
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
              onPressed: _navigateToShowcase,
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
                        Container(
                          margin: const EdgeInsets.only(bottom: 140.0, top: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50.0),
                            ),
                            onPressed: () {
                              setState(() {
                                _capturedImage = null;
                              });
                            },
                            child: const Text(
                              'Retake',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 140.0, top: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50.0),
                            ),
                            onPressed: () {
                              setState(() {
                                _capturedImages.add(_capturedImage!);
                                _capturedImage = null;
                              });
                            },
                            child: const Text(
                              'Use Photo',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _takePicture,
        tooltip: 'Take a Photo',
        label: Text('Capture Receipt'),
        icon: Icon(Icons.camera_alt),
      ),
    );
  }
}

class PhotoShowcase extends StatefulWidget {
  final List<File> images;
  final Future<void> Function(String folderName) onUpload;

  const PhotoShowcase({super.key, required this.images, required this.onUpload});

  @override
  PhotoShowcaseState createState() => PhotoShowcaseState();
}

class PhotoShowcaseState extends State<PhotoShowcase> {
  late List<bool> _selectedImages;
  late List<File> _currentImages;

  @override
  void initState() {
    super.initState();
    _selectedImages = List.generate(widget.images.length, (_) => false);
    _currentImages = List<File>.from(widget.images);
  }

  void _toggleSelection(int index) {
    setState(() {
      _selectedImages[index] = !_selectedImages[index];
    });
  }

  void _deleteSelectedImages() {
    setState(() {
      final toRemove = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        if (_selectedImages[i]) {
          toRemove.add(i);
        }
      }
      for (int i = toRemove.length - 1; i >= 0; i--) {
        _currentImages.removeAt(toRemove[i]);
        _selectedImages.removeAt(toRemove[i]);
      }
    });
  }

  Future<void> _showUploadDialog() async {
    String folderName = '';

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload to OneDrive'),
          content: TextField(
            onChanged: (value) {
              folderName = value;
            },
            decoration: InputDecoration(hintText: "Enter folder name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(folderName);
              },
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await widget.onUpload(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Showcase'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteSelectedImages,
          ),
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              Navigator.of(context).pop(_currentImages);
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: _currentImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _toggleSelection(index),
            child: GridTile(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_currentImages[index], fit: BoxFit.cover),
                  if (_selectedImages[index])
                    Container(
                      color: Colors.black54,
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        tooltip: 'Upload to OneDrive',
        label: Text('Upload to OneDrive'),
        icon: Icon(Icons.cloud_upload),
      ),
    );
  }
}
