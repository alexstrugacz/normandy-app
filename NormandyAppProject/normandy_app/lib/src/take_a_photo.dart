import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TakeAPhoto extends StatefulWidget {
  final String header;

  const TakeAPhoto({required this.header, super.key});

  @override
  TakeAPhotoState createState() => TakeAPhotoState();
}

class TakeAPhotoState extends State<TakeAPhoto> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  String recognizedText = '';

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    PermissionStatus status = await Permission.camera.request();
    print('Initial camera permission status: $status');

    if (status.isGranted) {
      setupCameras();
    } else if (status.isPermanentlyDenied) {
      showPermissionDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to take photos.'),
        ),
      );
    }
  }

  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Camera permission is permanently denied. Please enable it from the settings.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> setupCameras() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _controller = CameraController(cameras![0], ResolutionPreset.high);
      await _controller!.initialize();
      setState(() {
        isCameraInitialized = true;
      });
    }
  }

  Future<void> takePhoto() async {
    if (!_controller!.value.isInitialized) {
      return;
    }
    try {
      final XFile imageFile = await _controller!.takePicture();
      final String imagePath = imageFile.path;

      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      setState(() {
        this.recognizedText = recognizedText.text;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo taken and text recognized.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.header),
      ),
      body: isCameraInitialized
          ? Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller!),
                ),
                ElevatedButton(
                  onPressed: takePhoto,
                  child: const Text('Take Photo'),
                ),
                recognizedText.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(recognizedText),
                      )
                    : const SizedBox.shrink(),
              ],
            )
          : const Center(
              child: Text('Initializing Camera...'),
            ),
    );
  }
}
