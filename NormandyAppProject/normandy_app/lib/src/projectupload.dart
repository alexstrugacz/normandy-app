import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

import 'env.dart';

class ProjectUpload extends StatefulWidget {
  // TODO
  // [x] 1 - Get project list
  // [x] Display project list
  // [x] 2 - User tap on project
  // [x] Go to Upload/Capture image prompt
  // [x] 3a - Capture image
  // [x] User can click a button to capture an image
  // [x] User can click a button to finish (go to 4)
  // [x] User can click a button to cancel (go to 2 / images cleared)
  // [ ] 3b - Upload image
  // [ ] User will see their image gallery
  // [ ] User will be able to select images
  // [ ] User will be able to hit a button to finish (go to 4)
  // [x] 4 - Upload to OneDrive
  // [x] The images are uploaded to OneDrive

  const ProjectUpload({super.key});

  @override
  State<ProjectUpload> createState() => _ProjectUploadState();
}

class _ProjectUploadState extends State<ProjectUpload> {
  List<(String, String)> projects = [];
  bool loadingProjects = true;

  void initialize() async {
    print('initializing');
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");
    final token = await _getAccessToken();
    // Is there a way where we don't need to recursively scan all the directories?
    // I think that is what this API route is doing
    String? url =
        'https://graph.microsoft.com/v1.0/users/$email/drive/root/search(q=\'\')?\$select=name,remoteItem';
    // 'https://graph.microsoft.com/v1.0/users/$email/drive/root/search(q=\'\')';
    int length = 0;
    while (url != null) {
      print('URL ::: $url');
      try {
        final response = await http.get(Uri.parse(url), headers: {
          'Authorization': 'Bearer $token',
        });
        if (response.statusCode != 200) {
          throw Exception('${response.statusCode}');
        }
        final decoded = json.decode(response.body);
        length += decoded["value"].length as int;
        for (final element in decoded["value"]) {
          if (element["remoteItem"] == null) continue;
          setState(() {
            projects.add((element["name"], element["remoteItem"]["id"]));
          });
          print(element);
        }
        url = decoded["@odata.nextLink"];
      } catch (e) {
        print(e.toString());
        break;
      }
      break;
    }
    print('DONE: $length');
    setState(() {
      loadingProjects = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<String?> _getAccessToken() async {
    final String tenantId = TENANT_ID;
    final String clientId = CLIENT_ID;
    final String clientSCRT = CLIENT_SCRT;
    final String url =
        'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';

    final Map<String, String> body = {
      'client_id': clientId,
      'scope': 'https://graph.microsoft.com/.default',
      'client_secret': clientSCRT,
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
        // print('Access token: ${response.body}');
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['access_token'];
      } else {
        // print('Failed to get access token: ${response.body}');
        return null;
      }
    } catch (e) {
      // print('Error getting access token: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload to Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: loadingProjects
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: projects
                    .map((p) => ElevatedButton(
                          child: Text(p.$1),
                          onPressed: () {
                            Navigator.pushNamed(context, '/project-upload/page',
                                arguments: p);
                          },
                        ))
                    .toList(),
              ),
      ),
    );
  }
}

class ProjectUploadPage extends StatelessWidget {
  const ProjectUploadPage({super.key});

  static const List<({String name, String route})> buttons = [
    (name: 'Take Photo', route: '/project-upload/photo'),
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as (String, String);
    return Scaffold(
        appBar: AppBar(
          title: Text('Select Action | ${args.$1}'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  children: buttons.map((button) {
                    return ElevatedButton(
                      onPressed: () {
                        print('Pressed ${button.name}');
                        Navigator.pushNamed(context, button.route,
                            arguments: args);
                      },
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        button.name,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ));
  }
}

class ProjectUploadPhoto extends StatefulWidget {
  // late String header;

  const ProjectUploadPhoto({super.key});

  @override
  createState() => _ProjectUploadPhotoState();
}

class _ProjectUploadPhotoState extends State<ProjectUploadPhoto> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  List<File> _capturedImages = [];

  String? clientId;
  String? clientSCRT;
  String? tenantId;

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
      final XFile imageFile = await _cameraController.takePicture();

      setState(() {
        _capturedImages.add(File(imageFile.path));
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _uploadToOneDrive(String folderId) async {
    final String? accessToken = await _getAccessToken();

    if (accessToken == null) {
      print('Failed to get access token');
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString("email");

    if (email == null) {
      print('No email found in SharedPreferences');
      return;
    }

    final String userName = email.split('@').first;

    for (int i = 0; i < _capturedImages.length; i++) {
      final File image = _capturedImages[i];
      final String date = DateFormat('yyMMddTHHmmssSSS').format(DateTime.now());
      final String fileName =
          '$userName-$date-${(i + 1).toString().padLeft(4, '0')}.jpg';
      const activeProjects =
          'b!jAiYPxrRjUCBK5ovip7ZEQNDPo7LyL1OgeHRWtDKCLbYuzyahUg6R4iIfPdyhxQk';
      final String url =
          'https://graph.microsoft.com/v1.0/drives/$activeProjects/items/$folderId:/10. Photos/$fileName:/content';

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
          print('File uploaded successfully: $fileName');
          _showUploadSuccessDialog();
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

  void _showUploadSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Successful'),
          content: const Text('All images have been uploaded successfully.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToShowcase((String, String) args) async {
    final updatedImages = await Navigator.of(context).push<List<File>>(
      MaterialPageRoute(
        builder: (context) => PhotoShowcase(
          images: List<File>.from(_capturedImages),
          onUpload: () => _uploadToOneDrive(args.$2),
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
    final args = ModalRoute.of(context)!.settings.arguments as (String, String);
    return Scaffold(
      appBar: AppBar(
        title: Text('Take a Photo | ${args.$1}'),
        actions: [
          if (_capturedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () {
                _navigateToShowcase(args);
              },
            ),
        ],
      ),
      body: _isCameraInitialized
          ? CameraPreview(_cameraController)
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _takePicture,
        tooltip: 'Take a Photo',
        label: const Text('Capture Receipt'),
        icon: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class PhotoShowcase extends StatefulWidget {
  final List<File> images;
  final Future<void> Function() onUpload;

  const PhotoShowcase(
      {super.key, required this.images, required this.onUpload});

  @override
  State<PhotoShowcase> createState() => _PhotoShowcaseState();
}

class _PhotoShowcaseState extends State<PhotoShowcase> {
  late List<bool> _selectedImages;
  late List<File> _currentImages;

  _PhotoShowcaseState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Showcase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSelectedImages,
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              Navigator.of(context).pop(_currentImages);
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          widget.onUpload();
        },
        tooltip: 'Upload to OneDrive',
        label: const Text('Upload to OneDrive'),
        icon: const Icon(Icons.cloud_upload),
      ),
    );
  }
}
