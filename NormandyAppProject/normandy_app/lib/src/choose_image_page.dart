import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:normandy_app/src/take_a_photo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'env.dart';

class ChooseImagePage extends StatefulWidget {
  final String header;

  const ChooseImagePage({super.key, required this.header});

  @override
  ChooseImagePageState createState() => ChooseImagePageState();
}

class ChooseImagePageState extends State<ChooseImagePage> {
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
      clientId = clientId;
      clientSCRT = clientSecret;
      tenantId = tenantId;
    } catch (e) {
      if(kDebugMode) print('Error accessing environment variables: $e');
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

    for (int i = 0; i < _selectedImages.length; i++) {
      final File image = _selectedImages[i];
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
      if(kDebugMode) print('choosing $url');
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
          images: List<File>.from(_selectedImages),
          onUpload: (folderName) => _uploadToOneDrive(folderName),
        ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.header),
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.done),
              onPressed: _navigateToShowcase,
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
