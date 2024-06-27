import "package:flutter/material.dart";

class TakeAPhoto extends StatelessWidget {
  final String header;

  const TakeAPhoto({required this.header});

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
