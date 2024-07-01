import "package:flutter/material.dart";

class ChooseImage extends StatelessWidget {
  final String header;

  const ChooseImage({super.key, required this.header});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(header),
      ),
      body: Center(
        child: Text(header),
      ),
    );
  }
}
