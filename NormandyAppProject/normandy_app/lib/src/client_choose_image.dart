import 'dart:async';
import 'dart:math';

import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'env.dart';
import 'camera_screen.dart';

class ClientChooseImagePage extends StatefulWidget {
  final String name;
  const ClientChooseImagePage({super.key, required this.name});

  @override
  ClientChooseImagePageState createState() => ClientChooseImagePageState();
}

class ClientChooseImagePageState extends State<ClientChooseImagePage> {
  List<File> _selectedImages = [];
  final String _clientProjectsDriveId =
      "b!jAiYPxrRjUCBK5ovip7ZEQNDPo7LyL1OgeHRWtDKCLbYuzyahUg6R4iIfPdyhxQk";
  int? _selectedUploadType;
  String? _selectedClientFolderId;
  (int, int)? uploadProgress;

  static const List<String> folderPaths = [
    '10. Photos',
    '10. Photos/After Photos',
    '10. Photos/Site Visits',
    '70. Service',
    '45. Job Ready Documents',
    '08. Sal...ents/Misc/Client File Share',
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    List<XFile> pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages += pickedFiles.map((file) => File(file.path)).toList();
      });
      if (kDebugMode) print('Selected images: ${_selectedImages.length}');
    } else {
      if (kDebugMode) print('No images picked');
    }
  }

  Future<void> _clearImages() async {
    await Future.wait(_selectedImages.map((f) => f.delete()));
    setState(() {
      _selectedImages = [];
      uploadProgress = null;
    });
  }

  Future<void> _uploadToOneDrive() async {
    setState(() {
      uploadProgress = (0, _selectedImages.length);
    });
    final String? accessToken = await _getAccessToken();

    if (accessToken == null) {
      if (kDebugMode) print('Failed to get access token');
      await _showUploadFailureDialog(
          List.generate(_selectedImages.length, (i) => i));
      await _clearImages();
      return;
    }
    await _selectClientFolder(accessToken);

    if (_selectedClientFolderId == null) {
      if (kDebugMode) print('No client folder selected');
      return;
    }

    if (_selectedUploadType == null) {
      if (kDebugMode) print('No upload type selected');
      return;
    }

    List<int> failures = [];
    // TODO allow to cancel uploads
    for (int i = 0; i < _selectedImages.length; i++) {
      final File image = _selectedImages[i];
      final String date =
          DateFormat('yyyyMMddTHHmmssSSS').format(DateTime.now());
      final String fileName = '$date-${(i + 1).toString().padLeft(4, '0')}.jpg';
      final String folderPath = folderPaths[_selectedUploadType!];
      final String url =
          'https://graph.microsoft.com/v1.0/drives/$_clientProjectsDriveId/items/$_selectedClientFolderId:/$folderPath/$fileName:/content';

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
          if (kDebugMode) print('File uploaded successfully: $fileName');
        } else {
          // TODO show toast or some other notif on failure
          if (kDebugMode) print('File upload failed: ${response.body}');
          failures.add(i);
        }
      } catch (e) {
        if (kDebugMode) print('Error uploading file: $e');
        failures.add(i);
      }
      setState(() {
        uploadProgress = (i + 1, _selectedImages.length);
      });
    }
    if (failures.isEmpty) {
      await _showUploadSuccessDialog();
    } else {
      await _showUploadFailureDialog(failures);
    }
    await _clearImages();
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
        if (kDebugMode) print("getting access token");
        if (kDebugMode) print(response.body);
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (kDebugMode) print('Access token retrieved');
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

  Future<void> _selectClientFolder(String accessToken) async {
    if (kDebugMode) print("selecting client folder id");
    final String url =
        'https://graph.microsoft.com/v1.0/drives/$_clientProjectsDriveId/root:/${widget.name}';

    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _selectedClientFolderId = responseData['id'];
        if (kDebugMode) print(_selectedClientFolderId);
      } else if (response.statusCode == 404 && mounted) {
        if (kDebugMode) print('creating new folder');
        String create =
            'https://graph.microsoft.com/v1.0/drives/$_clientProjectsDriveId/root/children';
        response = await http.post(
          Uri.parse(create),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "name": widget.name,
            "folder": {},
            "@microsoft.graph.conflictBehavior": "fail"
          }),
        );
        if (response.statusCode != 201) {
          throw "Failed to create folder";
        }
        final Map<String, dynamic> responseData = json.decode(response.body);
        _selectedClientFolderId = responseData['id'];
        if (kDebugMode) print(_selectedClientFolderId);
      } else {
        if (kDebugMode) print('Failed to get client folders: ${response.body}');
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('Error getting client folders: $e');
        print(s.toString());
      }
    }
  }

  Future<void> _showUploadSuccessDialog() async {
    await showDialog(
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

  Future<void> _showUploadFailureDialog(List<int> failed) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Some Uploads Failed'),
          content:
              const Text('Would you like to save failed uploads to gallery?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                // TODO only save images from camera capture
                final nav = Navigator.of(context);
                final now = DateTime.now();
                final formattedDate = DateFormat('yyyy-MM-dd').format(now);
                await Future.wait(failed.map((i) {
                  return Gal.putImage(_selectedImages[i].path,
                      album: 'Normandy App - ${widget.name} - $formattedDate');
                }));
                if (mounted) nav.pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("client choose image");
      print(_selectedImages.length);
      print(_selectedClientFolderId);
    }
    final canUpload = _selectedImages.isNotEmpty &&
        _selectedUploadType != null &&
        uploadProgress == null;
    return Column(
      spacing: 20,
      children: [
        DropdownButton<int>(
          value: _selectedUploadType,
          hint: const Text('Select Upload Folder'),
          items: List.generate(folderPaths.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(folderPaths[index]),
            );
          }),
          onChanged: (value) {
            setState(() {
              _selectedUploadType = value;
            });
            if (kDebugMode) print('Selected upload type: $value');
          },
        ),
        Expanded(
          child: _selectedImages.isEmpty
              ? const Center(child: Text('No images selected'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Image(
                      image: FileImage(_selectedImages[index]),
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded || frame != null) {
                          return child;
                        } else {
                          return const Center(
                            child: Icon(Icons.image, color: Colors.grey),
                          );
                        }
                      },
                    );
                  },
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.extended(
              heroTag: null,
              onPressed: _pickImage,
              label: const Text('Gallery'),
              icon: const Icon(Icons.photo_library),
            ),
            FloatingActionButton.extended(
              heroTag: null,
              onPressed: () async {
                final newFiles = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CameraScreen()));
                setState(() {
                  _selectedImages += newFiles;
                });
              },
              label: const Text('Camera'),
              icon: const Icon(Icons.camera_alt),
            ),
          ],
        ),
        FloatingActionButton.extended(
          heroTag: null,
          onPressed: canUpload ? _uploadToOneDrive : null,
          backgroundColor: canUpload ? null : Colors.grey.shade400,
          foregroundColor: canUpload ? null : Colors.grey.shade800,
          label: (uploadProgress == null)
              ? const Text('Upload')
              : Row(spacing: 10, children: [
                  if (uploadProgress!.$1 != uploadProgress!.$2)
                    SpinningProgressIndicator(progress: uploadProgress!),
                  Text('Uploading ${uploadProgress!.$1}/${uploadProgress!.$2}'),
                ]),
          icon: const Icon(Icons.cloud_upload),
        ),
        if (_selectedImages.isEmpty)
          const Text('No images to upload',
              style: TextStyle(color: Color.fromRGBO(255, 0, 0, 1.0))),
        if (_selectedUploadType == null)
          const Text('No folder is selected',
              style: TextStyle(color: Color.fromRGBO(255, 0, 0, 1.0))),
      ],
    );
  }
}

class SpinningProgressIndicator extends StatefulWidget {
  final (int, int) progress;
  const SpinningProgressIndicator({super.key, required this.progress});

  @override
  State<StatefulWidget> createState() => _SpinningProgressIndicator();
}

class _SpinningProgressIndicator extends State<SpinningProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    final targetValue = max(0.1, progress.$1 / progress.$2);
    // return RotationTransition(
    //   turns: _spinController,
    //   // turns: AlwaysStoppedAnimation(0.25), // static rotation for demo
    //   child: TweenAnimationBuilder<double>(
    //       tween: Tween<double>(end: targetValue),
    //       duration: const Duration(milliseconds: 500),
    //       builder: (context, value, _) => CircularProgressIndicator(
    //           color: Colors.grey.shade600, value: value)),
    // );
    return TweenAnimationBuilder<double>(
        tween: Tween<double>(end: targetValue),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, _) {
          return RotationTransition(
              turns: _spinController,
              // turns: AlwaysStoppedAnimation(0.25), // static rotation for demo
              child: CircularProgressIndicator(
                  color: Colors.grey.shade600, value: value));
        });
  }
}
