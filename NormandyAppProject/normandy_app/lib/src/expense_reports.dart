import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:normandy_app/src/expensecodepage.dart';
import 'package:normandy_app/src/image_chooser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'env.dart';

class ExpenseReports extends StatelessWidget {
  const ExpenseReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Expense Reports')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child:
              // TODO how to pick folder name?
              ExpenseUploadPage(name: 'folderName'),
        ));
  }
}

class ExpenseUploadPage extends StatefulWidget {
  final String name;
  const ExpenseUploadPage({super.key, required this.name});

  @override
  State<ExpenseUploadPage> createState() => _ExpenseUploadPageState();
}

class _ExpenseUploadPageState extends State<ExpenseUploadPage> {
  final GlobalKey<ImageChooserState> imageChooser = GlobalKey();
  String? _operationsDriveId;

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
      if (kDebugMode) print('choosing $url');
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
              if (kDebugMode) {
                print('Found Documents Drive ID: $_operationsDriveId');
              }
            } else {
              if (kDebugMode) print('Drive named "Documents" not found.');
            }
          } else {
            if (kDebugMode) {
              print('Failed to get drives: ${drivesResponse.body}');
            }
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

  Future<void> _uploadToOneDrive() async {
    final ic = imageChooser.currentState!;
    ic.bumpProgress();
    final String? accessToken = await _getAccessToken();

    if (accessToken == null) {
      if (kDebugMode) print('Failed to get access token');
      return;
    }

    await getAllDrives(accessToken);

    if (_operationsDriveId == null) {
      if (kDebugMode) print('Drive named "Operations" not found');
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString("email");

    if (email == null) {
      if (kDebugMode) print('No email found in SharedPreferences');
      return;
    }

    final String userName = email.split('@').first;
    final String date = DateFormat('MMyyHms').format(DateTime.now());
    final String folderPath = 'nbexp_$userName-${widget.name}';

    for (int i = 0; i < ic.images.length; i++) {
      final File image = ic.images[i];
      final String fileName = '$date-${(i + 1).toString().padLeft(4, '0')}.jpg';
      final String path = '$folderPath/$fileName';
      final String url =
          'https://graph.microsoft.com/v1.0/drives/$_operationsDriveId/items/root:/Expenses/$path:/content';

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
          if (mounted) {
            await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseCodePage(
                    image: image,
                    imagePath: path,
                  ),
                ));
          }
          // _showUploadSuccessDialog();
        } else {
          if (kDebugMode) print('File upload failed: ${response.body}');
        }
      } catch (e) {
        if (kDebugMode) print('Error uploading file: $e');
      }
      ic.bumpProgress();
    }
    await ic.clearImages();
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

  @override
  Widget build(BuildContext context) {
    return ImageChooser(
        key: imageChooser,
        canUpload: true,
        onUpload: _uploadToOneDrive,
        refresh: () {
          setState(() {});
        });
  }
}
