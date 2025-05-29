import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'env.dart';
import 'camera_screen.dart';

class ClientChooseImagePage extends StatefulWidget {
  final String name;
  const ClientChooseImagePage({super.key, required this.name});

  @override
  ClientChooseImagePageState createState() =>
      ClientChooseImagePageState(name: name);
}

class ClientChooseImagePageState extends State<ClientChooseImagePage> {
  final String name;
  List<File> _selectedImages = [];
  String? _clientProjectsDriveId =
      "b!jAiYPxrRjUCBK5ovip7ZEQNDPo7LyL1OgeHRWtDKCLbYuzyahUg6R4iIfPdyhxQk";
  int? _selectedUploadType;
  String? _selectedClientFolderId;

  final List<String> folderPaths = [
    '10. Photos',
    '10. Photos/After Photos',
    '10. Photos/Site Visits',
    '70. Service',
    '45. Job Ready Documents',
    '08. Salesperson Documents/Misc/Client File Share',
  ];

  ClientChooseImagePageState({required this.name});

  @override
  void initState() {
    super.initState();
  }

  // DEPRECATED
  Future<void> _pickImageCamera() async {
    final ImagePicker imagePicker = ImagePicker();
    while (true) {
      XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
      if (file == null) break;
      setState(() {
        _selectedImages.add(File(file.path));
      });
      await Future.delayed(Duration(milliseconds: 500)); // tiny delay helps
    }
  }

  // DEPRECATED camera is always false
  Future<void> _pickImage({bool camera = false}) async {
    final ImagePicker picker = ImagePicker();
    if (camera) {
      await _pickImageCamera();
    } else {
      List<XFile> pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages +=
              pickedFiles.map((file) => File(file.path)).toList();
        });
        if (kDebugMode) print('Selected images: ${_selectedImages.length}');
      } else {
        if (kDebugMode) print('No images picked');
      }
    }
  }

  Future<void> _uploadToOneDrive() async {
    final String? accessToken = await _getAccessToken();

    if (accessToken == null) {
      if (kDebugMode) print('Failed to get access token');
      return;
    }
    await _selectClientFolder(accessToken);

    if (_clientProjectsDriveId == null) {
      if (kDebugMode) print('Drive named "Client Projects Active" not found');
      return;
    }

    if (_selectedClientFolderId == null) {
      if (kDebugMode) print('No client folder selected');
      return;
    }

    if (_selectedUploadType == null) {
      if (kDebugMode) print('No upload type selected');
      return;
    }

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
          _showUploadSuccessDialog();
        } else {
          if (kDebugMode) print('File upload failed: ${response.body}');
        }
      } catch (e) {
        if (kDebugMode) print('Error uploading file: $e');
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
        print("getting access token");
        print(response.body);
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

  Future<void> getAllDrives(String accessToken) async {
    /*
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

        final site = sites.firstWhere(
          (site) => site['name'] == 'Client Projects Active',
          orElse: () => null,
        );

        if (site != null) {
          final String clientProjectsSiteId = site['id'];
          final String drivesUrl =
              'https://graph.microsoft.com/v1.0/sites/$clientProjectsSiteId/drives';
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

            final drive = drives.firstWhere(
              (drive) => drive['name'] == 'Documents',
              orElse: () => null,
            );

            if (drive != null) {
              setState(() {
                _clientProjectsDriveId = drive['id'] as String?;
              });
              if (kDebugMode)
                print('Client Projects Active/Documents drive found');
            } else {
              if (kDebugMode) print('Drive named "Documents" not found.');
            }
          } else {
            if (kDebugMode)
              print('Failed to get drives: ${drivesResponse.body}');
          }
        } else {
          if (kDebugMode)
            print('Site named "Client Projects Active" not found.');
        }
      } else {
        if (kDebugMode) print('Failed to get sites: ${sitesResponse.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Error getting sites or drives: $e');
    }
  */
  }

  Future<void> _selectClientFolder(String accessToken) async {
    print("selecting client folder id");
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
        print(_selectedClientFolderId);
      } else if (response.statusCode == 404 && mounted) {
        print('creating new folder');
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
        print(_selectedClientFolderId);
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

  @override
  Widget build(BuildContext context) {
    print("client choose image");
    print(_selectedImages.length);
    print(_selectedClientFolderId);
    return Column(
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
              //onPressed: () => _pickImage(camera: true),
              onPressed: () async {
                final newFiles = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CameraScreen()));
                if (newFiles != null) {
                  setState(() {
                    _selectedImages += newFiles;
                  });
                }
              },
              label: Text('Camera'),
              icon: Icon(Icons.camera_alt),
            ),
          ],
        ),
        if (_selectedImages.isNotEmpty && _selectedUploadType != null)
          FloatingActionButton.extended(
            onPressed: _uploadToOneDrive,
            label: Text('Upload Images'),
            icon: Icon(Icons.cloud_upload),
          ),
      ],
    );
  }
}
