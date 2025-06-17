import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:normandy_app/main.dart';
import 'package:flutter/foundation.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  late double _minZoom;
  late double _maxZoom;
  double _currentZoom = 1.0;
  double _lastZoom = 1.0;
  double _baseZoom = 1.0;

  List<File> files = [];
  double _overlayOpacity = 0.0;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras[0], // usually back camera
      ResolutionPreset.max,
      enableAudio: false,
    );
    _initializeControllerFuture = initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    await _controller.initialize();
    _minZoom = await _controller.getMinZoomLevel();
    //print("minZoom: $_minZoom");
    _maxZoom = await _controller.getMaxZoomLevel();
  }

  Future<void> _takePicture() async {
    try {
      final image = await _controller.takePicture();
      // Start the shutter effect (semi-transparent black)k
      setState(() => _overlayOpacity = 0.5);

      // Wait a short duration for the shutter effect
      await Future.delayed(const Duration(milliseconds: 100));

      // Fade it back out
      setState(() => _overlayOpacity = 0.0);

      // TODO photos taken in landscape are sideways
      files.add(File(image.path));
    } catch (e) {
      if (kDebugMode) {
        print('Error taking picture: $e');
      }
      // consider rethrow, but we don't want to stop at errors I think
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
                  // look at ResolutionPreset's and also manual image transformation
                  // or hopefully there will be a better way
                  child: Transform.scale(
                    scale: scale,
                    child: CameraPreview(_controller),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _overlayOpacity,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onScaleStart: (_) => _baseZoom = _currentZoom,
                  onScaleUpdate: (details) async {
                    _currentZoom =
                        (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);
                    if ((_currentZoom - _lastZoom).abs() > 0.05) {
                      _lastZoom = _currentZoom;
                      _controller.setZoomLevel(_currentZoom);
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                if (!_isCapturing)
                  Positioned(
                    bottom: isLandscape ? 0 : 30,
                    top: isLandscape ? 0 : null,
                    left: isLandscape ? null : 0,
                    right: isLandscape ? 30 : 0,
                    child: Center(
                      child: FloatingActionButton(
                        heroTag: null,
                        onPressed: () async {
                          setState(() => _isCapturing = true);
                          await _takePicture();
                          setState(() => _isCapturing = false);
                        },
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: isLandscape ? 20 : 30,
                  left: isLandscape ? null : 20,
                  right: isLandscape ? 30 : null,
                  child: Center(
                    child: FloatingActionButton(
                      heroTag: null,
                      mini: true,
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      onPressed: () {
                        Navigator.pop(context, files);
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
