import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'env.dart';

class ClientChooseImagePage extends StatefulWidget {
  final String header;

  const ClientChooseImagePage({Key? key, required this.header})
      : super(key: key);

  @override
  _ClientChooseImagePageState createState() => _ClientChooseImagePageState();
}

class _ClientChooseImagePageState extends State<ClientChooseImagePage> {
  List<File> _selectedImages = [];
  String? clientId;
  String? clientSCRT;
  String? tenantId;
  String? _clientProjectsDriveId;
  String? _selectedUploadType;
  String? _selectedClientFolderId;

  final List<String> uploadTypes = [
    'Upload Client Photos',
    'Upload After Photos',
    'Upload Site Visits',
    'Upload Service',
    'Upload Job Ready Documents',
    'Upload Plat/Existing Home Docs'
  ];

  final Map<String, String> folderPaths = {
    'Upload Client Photos': '10. Photos',
    'Upload After Photos': '10. Photos/After Photos',
    'Upload Site Visits': '10. Photos/Site Visits',
    'Upload Service': '70. Service',
    'Upload Job Ready Documents': '45. Job Ready Documents',
    'Upload Plat/Existing Home Docs':
        '08. Salesperson Documents/Misc/Client File Share'
  };

  @override
  void initState() {
    super.initState();
    _initializeEnvVariables();
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

  Future<void> _pickImage() async {
    if (await Permission.storage.request().isGranted) {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? pickedFiles = await picker.pickMultiImage();

      if (pickedFiles != null) {
        setState(() {
          _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
        });
        print('Selected images: ${_selectedImages.length}');
      } else {
        print('No images picked');
      }
    } else {
      print('Storage permission denied');
    }
  }

  Future<void> _uploadToOneDrive() async {
    final String? accessToken = await _getAccessToken();

    if (accessToken == null) {
      print('Failed to get access token');
      return;
    }

    if (_clientProjectsDriveId == null) {
      print('Drive named "Client Projects Active" not found');
      return;
    }

    if (_selectedClientFolderId == null) {
      print('No client folder selected');
      return;
    }

    for (int i = 0; i < _selectedImages.length; i++) {
      final File image = _selectedImages[i];
      final String fileName = (i + 1).toString().padLeft(4, '0') + '.jpg';
      final String folderPath = folderPaths[_selectedUploadType] ?? '';
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
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Access token retrieved');
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
              print('Client Projects Active/Documents drive found');
            } else {
              print('Drive named "Documents" not found.');
            }
          } else {
            print('Failed to get drives: ${drivesResponse.body}');
          }
        } else {
          print('Site named "Client Projects Active" not found.');
        }
      } else {
        print('Failed to get sites: ${sitesResponse.body}');
      }
    } catch (e) {
      print('Error getting sites or drives: $e');
    }
  }

  Future<void> _selectClientFolder(String accessToken) async {
    final String url =
        'https://graph.microsoft.com/v1.0/drives/$_clientProjectsDriveId/root:/Documents:/children';

    try {
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> folders = data['value'];

        print('Retrieved ${folders.length} client folders');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Select Client Folder'),
              content: SingleChildScrollView(
                child: Column(
                  children: folders.map((folder) {
                    return ListTile(
                      title: Text(folder['name']),
                      onTap: () {
                        setState(() {
                          _selectedClientFolderId = folder['id'];
                        });
                        Navigator.of(context).pop();
                        print('Selected folder: ${folder['name']}');
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      } else {
        print('Failed to get client folders: ${response.body}');
      }
    } catch (e) {
      print('Error getting client folders: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.header),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedUploadType,
            hint: Text('Select Upload Type'),
            items: uploadTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedUploadType = value;
              });
              print('Selected upload type: $value');
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
                      return Image.file(_selectedImages[index]);
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton.extended(
                onPressed: _pickImage,
                label: Text('Pick Images'),
                icon: Icon(Icons.photo_library),
              ),
              FloatingActionButton.extended(
                onPressed: () async {
                  final String? accessToken = await _getAccessToken();
                  if (accessToken != null) {
                    print('Fetching client folders...');
                    _selectClientFolder(accessToken);
                  }
                },
                label: Text('Select Client Folder'),
                icon: Icon(Icons.folder_open),
              ),
              if (_selectedImages.isNotEmpty && _selectedClientFolderId != null)
                FloatingActionButton.extended(
                  onPressed: _uploadToOneDrive,
                  label: Text('Upload Images'),
                  icon: Icon(Icons.cloud_upload),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
