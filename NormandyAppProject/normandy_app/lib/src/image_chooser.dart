import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:normandy_app/src/camera_screen.dart';

class ImageChooser extends StatefulWidget {
  final bool canUpload;
  final Future<void> Function() upload;
  final void Function() refresh;

  const ImageChooser({
    super.key,
    required this.canUpload,
    required this.upload,
    required this.refresh,
  });

  @override
  State<ImageChooser> createState() => ImageChooserState();
}

class ImageChooserState extends State<ImageChooser> {
  final List<File> _images = [];
  (int, int)? _progress;
  List<File> get images => List.unmodifiable(_images);
  (int, int)? get progress => _progress;

  void addAll(Iterable<File> newFiles) {
    final empty = _images.isEmpty;
    _images.addAll(newFiles);
    if (empty) {
      widget.refresh();
    } else {
      setState(() {});
    }
  }

  bool canUpload() {
    return images.isNotEmpty && progress == null;
  }

  void bumpProgress() {
    if (progress == null) {
      setState(() => _progress = (0, images.length));
    } else {
      setState(() => _progress = (_progress!.$1 + 1, images.length));
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    List<XFile> pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      addAll(pickedFiles.map((file) => File(file.path)));
      if (kDebugMode) print('Selected images: ${images.length}');
    } else {
      if (kDebugMode) print('No images picked');
    }
  }

  Future<void> clearImages() async {
    await Future.wait(images.map((f) => f.delete()));
    _images.clear();
    _progress = null;
    widget.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final canUpload = widget.canUpload && this.canUpload();
    return Column(
      spacing: 20,
      children: [
        Expanded(
          child: images.isEmpty
              ? const Center(child: Text('No images selected'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Image(
                      image: FileImage(images[index]),
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded || frame != null) {
                          return child;
                        } else {
                          return const Center(
                            child: Icon(Icons.image, color: Colors.grey),
                          );
                        }
                      },
                    );
                  },
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.extended(
              heroTag: null,
              onPressed: _pickImage,
              label: const Text('Gallery'),
              icon: const Icon(Icons.photo_library),
            ),
            FloatingActionButton.extended(
              heroTag: null,
              onPressed: () async {
                final newFiles = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CameraScreen()));
                addAll(newFiles);
              },
              label: const Text('Camera'),
              icon: const Icon(Icons.camera_alt),
            ),
          ],
        ),
        FloatingActionButton.extended(
          heroTag: null,
          onPressed: canUpload ? widget.upload : null,
          backgroundColor: canUpload ? null : Colors.grey.shade400,
          foregroundColor: canUpload ? null : Colors.grey.shade800,
          label: (progress == null)
              ? const Text('Upload')
              : Row(spacing: 10, children: [
                  if (progress!.$1 != progress!.$2)
                    SpinningProgressIndicator(progress: progress!),
                  Text('Uploading ${progress!.$1}/${progress!.$2}'),
                ]),
          icon: const Icon(Icons.cloud_upload),
        ),
      ],
    );
  }
}

class SpinningProgressIndicator extends StatefulWidget {
  final (int, int) progress;
  const SpinningProgressIndicator({super.key, required this.progress});

  @override
  State<StatefulWidget> createState() => _SpinningProgressIndicator();
}

class _SpinningProgressIndicator extends State<SpinningProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    final targetValue = max(0.1, progress.$1 / progress.$2);
    // return RotationTransition(
    //   turns: _spinController,
    //   // turns: AlwaysStoppedAnimation(0.25), // static rotation for demo
    //   child: TweenAnimationBuilder<double>(
    //       tween: Tween<double>(end: targetValue),
    //       duration: const Duration(milliseconds: 500),
    //       builder: (context, value, _) => CircularProgressIndicator(
    //           color: Colors.grey.shade600, value: value)),
    // );
    return TweenAnimationBuilder<double>(
        tween: Tween<double>(end: targetValue),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, _) {
          return RotationTransition(
              turns: _spinController,
              // turns: AlwaysStoppedAnimation(0.25), // static rotation for demo
              child: CircularProgressIndicator(
                  color: Colors.grey.shade600, value: value));
        });
  }
}
