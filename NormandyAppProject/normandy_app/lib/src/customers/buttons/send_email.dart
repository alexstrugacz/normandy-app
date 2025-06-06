import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailButton extends StatelessWidget {
  final String email;

  const EmailButton({
    super.key,
    required this.email,
  });

  bool determineValidEmail() {
    return email.isNotEmpty && email.contains('@');
  }

  void openMailApp() {
    if(!determineValidEmail()) return;
    launchUrl(Uri.parse('mailto:$email'));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openMailApp(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.email,
          size: 28,
          color: (determineValidEmail() ? Colors.blue : Colors.grey),
        ),
      ),
    );
  }
}