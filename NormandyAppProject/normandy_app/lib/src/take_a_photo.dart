import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(cameras![0], ResolutionPreset.high);
        await _controller!.initialize();
        setState(() {
          isCameraInitialized = true;
        });
      }
    } else {
        if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Camera permission is required to take photos.')),
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
          ? CameraPreview(_controller!)
          : const Center(
              child: Text('Initializing Camera...'),
            ),
    );
  }
}
