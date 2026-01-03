import 'dart:async';

import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/customers/jobs_type.dart';
import 'package:normandy_app/src/api/api_helper.dart';

import 'package:normandy_app/src/image_chooser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'env.dart';

class ClientChooseImagePage extends StatefulWidget {
  final String name;
  final String customerId;
  const ClientChooseImagePage({super.key, required this.name, required this.customerId});

  @override
  State<ClientChooseImagePage> createState() => _ClientChooseImagePageState();
}

class _ClientChooseImagePageState extends State<ClientChooseImagePage> {
  SharedPreferences? prefs;
  final String _clientProjectsDriveId =
      "b!jAiYPxrRjUCBK5ovip7ZEQNDPo7LyL1OgeHRWtDKCLbYuzyahUg6R4iIfPdyhxQk";
  final GlobalKey<ImageChooserState> imageChooser = GlobalKey();
  int? _selectedUploadType;
  int? _selectedJobType;
  String? _selectedClientFolderId;
  List<Job> jobs = [];

  static const List<String> folderPaths = [
    '10. Photos',
    '10. Photos/After Photos',
    '10. Photos/Site Visits',
    '70. Service',
    '45. Job Ready Documents',
    '08. Salesperson Documents/Misc/Client File Share',
  ];

  Future<void> _uploadToOneDrive() async {
    if (imageChooser.currentState == null) return;
    final ic = imageChooser.currentState!;
    ic.bumpProgress();
    final String? accessToken = await _getAccessToken();

    if (accessToken == null) {
      if (kDebugMode) print('Failed to get access token');
      await _showUploadFailureDialog(ic.images);
      await ic.clearImages();
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

    List<File> failures = [];
    List<String> uploadedImageNames = [];
    // TODO allow to cancel uploads
    for (int i = 0; i < ic.images.length; i++) {
      final File image = ic.images[i];
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
          uploadedImageNames.add(fileName);
        } else {
          // TODO show toast or some other notif on failure
          if (kDebugMode) print('File upload failed: ${response.body}');
          failures.add(image);
        }
      } catch (e) {
        if (kDebugMode) print('Error uploading file: $e');
        failures.add(image);
      }
      ic.bumpProgress();
    }

    prefs ??= await SharedPreferences.getInstance();

    try {
      await APIHelper.post(
        'site-visits/check-site-visits?jobId=${jobs[_selectedJobType!].id}&userId=${prefs!.getString('userId') ?? ''}&customerId=${widget.customerId}',
        {'imageIdentifiers': uploadedImageNames},
        context,
        mounted);
    } catch (e) {
      if (kDebugMode) print('Error during upload process: $e');
    }

    if (failures.isEmpty) {
      await _showUploadSuccessDialog();
    } else {
      await _showUploadFailureDialog(failures);
    }
    await ic.clearImages();
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

  Future<void> _showUploadFailureDialog(List<File> failed) async {
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
                // TODO maybe only save images from camera capture
                final nav = Navigator.of(context);
                final now = DateTime.now();
                final formattedDate =
                    DateFormat('yyyy-MM-dd').add_jm().format(now);
                await Future.wait(failed.map((f) {
                  return Gal.putImage(f.path,
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

   Future<List<Job>> _getJobsForCustomer() async {
    var jobsResponse = await APIHelper.get(
        'projects?customerId=${widget.customerId}&includeJobStateName=true',
        context,
        mounted);
    if (jobsResponse != null && jobsResponse.statusCode == 200) {
      var newJobs = (json.decode(jobsResponse.body)['projects'] as List)
          .map((job) => Job.fromJson(job))
          .toList();
      return newJobs;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("client choose image");
      print(imageChooser.currentState?.images.length);
      print(_selectedClientFolderId);
    }
    final canUpload = _selectedUploadType != null;
    return Column(
      spacing: 20,
      children: [
        DropdownButton<int>(
          value: _selectedUploadType,
          hint: const Text('Select Upload Folder'),
          items: List.generate(folderPaths.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(
                folderPaths[index],
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
          onChanged: (value) async {
            setState(() {
              _selectedUploadType = value;
            });
            if (kDebugMode) print('Selected upload type: $value');
            var newJobs = await _getJobsForCustomer();
            setState(() {
              jobs = newJobs;
            });
          },
        ),
        (_selectedUploadType == 2)
            ? (
              DropdownButton<int>(
                value: _selectedJobType,
                hint: const Text('Select Job'),
                items: List.generate(jobs.length, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                      '${jobs[index].jobNumber} - ${DateFormat('MM/dd/yyyy').format(jobs[index].dateSold ?? DateTime.now())} - ${jobs[index].jobDescription ?? ''}', 
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedJobType = value;
                  });
                  if (kDebugMode) print('Selected job type: $value');
                },
              )
              )
            : (const Text('')),
        Flexible(
          child: ImageChooser(
              key: imageChooser,
              canUpload: canUpload,
              onUpload: _uploadToOneDrive,
              refresh: () {
                setState(() {});
              }),
        ),
        if (imageChooser.currentState?.images.isEmpty ?? false)
          const Text('No images to upload',
              style: TextStyle(color: Color.fromRGBO(255, 0, 0, 1.0))),
        if (_selectedUploadType == null)
          const Text('No folder is selected',
              style: TextStyle(color: Color.fromRGBO(255, 0, 0, 1.0))),
      ],
    );
  }
}
