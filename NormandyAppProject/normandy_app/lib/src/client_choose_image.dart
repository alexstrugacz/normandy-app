import 'dart:async';

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
  late String name;
  List<File> _selectedImages = [];
  final String _clientProjectsDriveId =
      "b!jAiYPxrRjUCBK5ovip7ZEQNDPo7LyL1OgeHRWtDKCLbYuzyahUg6R4iIfPdyhxQk";
  int? _selectedUploadType;
  String? _selectedClientFolderId;
  (int, int)? uploadProgress;

  final List<String> folderPaths = [
    '10. Photos',
    '10. Photos/After Photos',
    '10. Photos/Site Visits',
    '70. Service',
    '45. Job Ready Documents',
    '08. Sal...ents/Misc/Client File Share',
  ];

  @override
  void initState() {
    super.initState();
    name = widget.name;
  }

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

  Future<void> _uploadToOneDrive() async {
    setState(() {
      uploadProgress = (0, _selectedImages.length);
    });
    final String? accessToken = await _getAccessToken();

    if (accessToken == null) {
      if (kDebugMode) print('Failed to get access token');
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

    var failures = [];
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
          if (kDebugMode) print('File upload failed: ${response.body}');
          failures.add(i);
        }
      } catch (e) {
        if (kDebugMode) print('Error uploading file: $e');
      }
      setState(() {
        uploadProgress = (i + 1, _selectedImages.length);
      });
    }
    if (failures.isEmpty) {
      await _showUploadSuccessDialog();
      setState(() {
        _selectedImages = [];
      });
    } else {
      await _showUploadFailureDialog();
      List<File> newSelected = [];
      for (final i in failures) {
        newSelected.add(_selectedImages[i]);
      }
      setState(() {
        _selectedImages = newSelected;
      });
    }
    setState(() {
      uploadProgress = null;
    });
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
        'https://graph.microsoft.com/v1.0/drives/$_clientProjectsDriveId/root:/$name';

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
            "name": name,
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

  Future<void> _showUploadFailureDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Some Uploads Failed'),
          content: Text('The failed images are the ones still remaining.'),
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

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print("client choose image");
    if (kDebugMode) print(_selectedImages.length);
    if (kDebugMode) print(_selectedClientFolderId);
    final canUpload = _selectedImages.isNotEmpty &&
        _selectedUploadType != null &&
        uploadProgress == null;
    return Column(
      spacing: 20,
      children: [
        DropdownButton<int>(
          value: _selectedUploadType,
          hint: Text('Select Upload Folder'),
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
              ? Center(child: Text('No images selected'))
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          return Center(
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
              onPressed: _pickImage,
              label: Text('Gallery'),
              icon: Icon(Icons.photo_library),
            ),
            FloatingActionButton.extended(
              onPressed: () async {
                final newFiles = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CameraScreen()));
                setState(() {
                  _selectedImages += newFiles;
                });
              },
              label: Text('Camera'),
              icon: Icon(Icons.camera_alt),
            ),
          ],
        ),
        FloatingActionButton.extended(
          onPressed: canUpload ? _uploadToOneDrive : null,
          backgroundColor: canUpload ? null : Colors.grey.shade400,
          foregroundColor: canUpload ? null : Colors.grey.shade800,
          label: (uploadProgress == null)
              ? Text('Upload')
              : Row(spacing: 10, children: [
                  CircularProgressIndicator(
                      color: Colors.grey.shade600,
                      value: uploadProgress!.$1 / uploadProgress!.$2),
                  Text('Uploading ${uploadProgress!.$1}/${uploadProgress!.$2}'),
                ]),
          icon: Icon(Icons.cloud_upload),
        ),
        if (_selectedImages.isEmpty)
          Text('No images to upload',
              style: TextStyle(color: Color.fromRGBO(255, 0, 0, 1.0))),
        if (_selectedUploadType == null)
          Text('No folder is selected',
              style: TextStyle(color: Color.fromRGBO(255, 0, 0, 1.0))),
      ],
    );
  }
}
