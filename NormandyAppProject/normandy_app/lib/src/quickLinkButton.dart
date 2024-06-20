import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickLinkButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final String url;

  QuickLinkButton(
      {required this.label, required this.imagePath, required this.url});

  Future<void> _launchURL() async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch the URL.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchURL,
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 70, width: 70),
            SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
