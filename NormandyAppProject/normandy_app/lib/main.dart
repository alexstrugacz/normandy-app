import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'src/app.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    cameras = [];
  }
  runApp(const MyApp());
}
