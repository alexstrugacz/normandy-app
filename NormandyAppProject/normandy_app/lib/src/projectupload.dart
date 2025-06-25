import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

import 'env.dart';

Future<void> _uploadToOneDrive(List<File> images, String folderId) async {
  final String? accessToken = await _getAccessToken();

  if (accessToken == null) {
    if (kDebugMode) print('Failed to get access token');
    return;
  }

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? email = prefs.getString("email");

  if (email == null) {
    if (kDebugMode) print('No email found in SharedPreferences');
    return;
  }

  final String userName = email.split('@').first;

  for (int i = 0; i < images.length; i++) {
    final File image = images[i];
    final String date = DateFormat('yyMMddTHHmmssSSS').format(DateTime.now());
    final String fileName =
        '$userName-$date-${(i + 1).toString().padLeft(4, '0')}.jpg';
    const activeProjects =
        'b!jAiYPxrRjUCBK5ovip7ZEQNDPo7LyL1OgeHRWtDKCLbYuzyahUg6R4iIfPdyhxQk';
    final String url =
        'https://graph.microsoft.com/v1.0/drives/$activeProjects/items/$folderId:/10. Photos/$fileName:/content';

    final List<int> fileBytes = await image.readAsBytes();

    final http.Response response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/octet-stream',
      },
      body: fileBytes,
    );

    if (response.statusCode == 201) {
      if (kDebugMode) print('File uploaded successfully: $fileName');
    } else {
      throw Exception("file not uploaded");
      // if(kDebugMode) print('File upload failed: ${response.body}');
    }
  }
}

Future<String?> _getAccessToken() async {
  final String url =
      'https://login.microsoftonline.com/$TENANT_ID/oauth2/v2.0/token';

  final Map<String, String> body = {
    'client_id': CLIENT_ID,
    'scope': 'https://graph.microsoft.com/.default',
    'client_secret': CLIENT_SCRT,
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
      if (kDebugMode) print('Access token: ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['access_token'];
    } else {
      if (kDebugMode) print('Failed to get access token: ${response.body}');
      return null;
    }
  } catch (e) {
    if (kDebugMode) print('Error getting access token: $e');
    return null;
  }
}

class ProjectUpload extends StatefulWidget {
  const ProjectUpload({super.key});

  @override
  State<ProjectUpload> createState() => _ProjectUploadState();
}

class _ProjectUploadState extends State<ProjectUpload> {
  List<(String, String)> projects = [];
  bool loadingProjects = true;

  void initialize() async {
    if (kDebugMode) print('initializing');
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");
    final token = await _getAccessToken();
    // Is there a way where we don't need to recursively scan all the directories?
    // I think that is what this API route is doing
    String? url =
        // 'https://graph.microsoft.com/v1.0/users/$email/drive/root/search(q=\'\')';
        // 'https://graph.microsoft.com/v1.0/users/$email/drive/root/search(q=\' - \')?\$select=name,remoteItem';
        // 'https://graph.microsoft.com/v1.0/users/$email/drive/root/search(q=\'name:-\')?\$select=name,remoteItem';
        // TODO enforce that shortcuts are created in this folder
        // 'https://graph.microsoft.com/v1.0/users/$email/drive/root/search(q=\'\')?\$select=name,remoteItem';
        // 'https://graph.microsoft.com/v1.0/users/$email/drive/root:/Shortcuts:/search(q=\'\')?\$select=name,remoteItem';
        'https://graph.microsoft.com/v1.0/users/$email/drive/root:/Shortcuts:/search(q=\'\')?\$select=name,remoteItem';
    int length = 0;
    while (url != null) {
      if (kDebugMode) print('URL ::: $url');
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
          if (kDebugMode) print(element["name"]);
          if (element["remoteItem"] == null) continue;
          setState(() {
            projects.add((element["name"], element["remoteItem"]["id"]));
          });
        }
        url = decoded["@odata.nextLink"];
      } catch (e) {
        if (kDebugMode) print(e.toString());
        break;
      }
      // break;
    }
    if (kDebugMode) print('DONE: $length');
    setState(() {
      loadingProjects = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
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
    (name: 'Select from Gallery', route: '/project-upload/gallery'),
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as (String, String);
    return Scaffold(
        appBar: AppBar(
          title: Text(args.$1),
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
                        if (kDebugMode) print('Pressed ${button.name}');
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
      if (kDebugMode) print('Error accessing environment variables: $e');
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
      if (kDebugMode) print('Camera permission not granted');
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
        if (kDebugMode) print('No cameras available');
      }
    } catch (e) {
      if (kDebugMode) print('Error initializing camera: $e');
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
      if (kDebugMode) print('Error taking picture: $e');
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
          onUpload: () async {
            try {
              await _uploadToOneDrive(_capturedImages, args.$2);
              _showUploadSuccessDialog();
            } catch (e) {
              if (kDebugMode) print(e.toString());
            }
          },
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

class ProjectUploadGallery extends StatefulWidget {
  const ProjectUploadGallery({super.key});

  @override
  State<ProjectUploadGallery> createState() => _ProjectUploadGalleryState();
}

class _ProjectUploadGalleryState extends State<ProjectUploadGallery> {
  List<File> _selectedImages = [];
  String? clientId;
  String? clientSCRT;
  String? tenantId;
  String? _operationsDriveId;

  @override
  void initState() {
    super.initState();
    _initializeEnvVariables();
    _pickImage();
  }

  void _initializeEnvVariables() {
    try {
      clientId = CLIENT_ID;
      clientSCRT = CLIENT_SCRT;
      tenantId = TENANT_ID;
    } catch (e) {
      if (kDebugMode) print('Error accessing environment variables: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
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
          if (kDebugMode) print('No sites found.');
          return;
        }

        final site = sites.firstWhere(
          (site) => site['name'] == 'Operations',
          orElse: () => null,
        );

        if (site != null) {
          final String operationsSiteId = site['id'];
          if (kDebugMode) print('Found Operations Site ID: $operationsSiteId');

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
              if (kDebugMode) print('No drives found for Operations site.');
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
              if (kDebugMode)
                print('Found Documents Drive ID: $_operationsDriveId');
            } else {
              if (kDebugMode) print('Drive named "Documents" not found.');
            }
          } else {
            if (kDebugMode)
              print('Failed to get drives: ${drivesResponse.body}');
          }
        } else {
          if (kDebugMode) print('Site named "Operations" not found.');
        }
      } else {
        if (kDebugMode) print('Failed to get sites: ${sitesResponse.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Error getting sites or drives: $e');
    }
  }

  void _showUploadSuccessDialog() {
    if (kDebugMode) print("showing dialog");
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

  Future<void> _navigateToShowcase((String, String) args) async {
    final updatedImages = await Navigator.of(context).push<List<File>>(
      MaterialPageRoute(
        builder: (context) => PhotoShowcase(
            images: List<File>.from(_selectedImages),
            onUpload: () async {
              try {
                await _uploadToOneDrive(
                    List<File>.from(_selectedImages), args.$2);
                _showUploadSuccessDialog();
              } catch (e) {
                if (kDebugMode) print(e.toString());
              }
            }),
      ),
    );

    if (updatedImages != null) {
      setState(() {
        _selectedImages = updatedImages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as (String, String);
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload from Gallery | ${args.$1}'),
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () {
                _navigateToShowcase(args);
              },
            ),
        ],
      ),
      body: _selectedImages.isEmpty
          ? Center(child: Text('No images selected'))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Image.file(_selectedImages[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage,
        label: Text('Pick More Images'),
        icon: Icon(Icons.photo_library),
      ),
    );
  }
}
