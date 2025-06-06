import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'src/app.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}
