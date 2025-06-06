import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:normandy_app/main.dart';

class CameraScreen extends StatefulWidget {
  CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  List<File> files = [];
  double _overlayOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras[0], // usually back camera
      ResolutionPreset.max,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      setState(() {
        _overlayOpacity =
            0.5; // Start the shutter effect (semi-transparent black)
      });

      // Wait a short duration for the shutter effect
      await Future.delayed(Duration(milliseconds: 100));

      setState(() {
        _overlayOpacity = 0.0; // Fade it back out
      });

      final image = await _controller.takePicture();
      // TODO photos taken in landscape are sideways
      files.add(File(image.path));
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final isLandscape =
                MediaQuery.of(context).orientation == Orientation.landscape;
            final size = MediaQuery.of(context).size;
            final deviceRatio = size.aspectRatio;
            final previewRatio = _controller.value.aspectRatio;
            final scale = deviceRatio >= previewRatio
                ? deviceRatio / previewRatio
                : 1 / (deviceRatio * previewRatio);
            return Stack(
              children: [
                OverflowBox(
                  maxHeight: size.height,
                  maxWidth: size.width,
                  // only preview is cropped, NOT actual image
                  // maybe an issue
                  child: Transform.scale(
                    scale: scale,
                    child: CameraPreview(_controller),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _overlayOpacity,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  bottom: isLandscape ? 0 : 30,
                  top: isLandscape ? 0 : null,
                  left: isLandscape ? null : 0,
                  right: isLandscape ? 30 : 0,
                  child: Center(
                    child: FloatingActionButton(
                      child: Icon(Icons.camera_alt),
                      onPressed: _takePicture,
                    ),
                  ),
                ),
                Positioned(
                  bottom: isLandscape ? 20 : 30,
                  left: isLandscape ? null : 20,
                  right: isLandscape ? 30 : null,
                  child: Center(
                    child: FloatingActionButton(
                      child: Icon(Icons.arrow_back, color: Colors.white),
                      mini: true,
                      backgroundColor: Colors.black.withOpacity(0.5),
                      onPressed: () {
                        Navigator.pop(context, files);
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}