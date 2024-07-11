import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class TakeAPhoto extends StatefulWidget {
  final String header;

  const TakeAPhoto({Key? key, required this.header}) : super(key: key);

  @override
  _TakeAPhotoState createState() => _TakeAPhotoState();
}

class _TakeAPhotoState extends State<TakeAPhoto> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      _initializeCamera();
    } else {
      // Handle the case when the permission is not granted
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }

    if (_cameraController!.value.isTakingPicture) {
      return;
    }

    try {
      final XFile? imageFile = await _cameraController!.takePicture();

      if (imageFile == null) {
        throw Exception('Error: Image file is null');
      }

      await _processImage(File(imageFile.path));
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      final recognizedText =
          await FlutterTesseractOcr.extractText(imageFile.path);
      setState(() {
        _recognizedText = recognizedText;
      });
    } catch (e) {
      print('Error recognizing text: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.header),
      ),
      body: _isCameraInitialized
          ? Column(
              children: [
                Expanded(child: CameraPreview(_cameraController!)),
                Text(_recognizedText),
                ElevatedButton(
                  onPressed: _takePicture,
                  child: Text('Take Photo'),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
