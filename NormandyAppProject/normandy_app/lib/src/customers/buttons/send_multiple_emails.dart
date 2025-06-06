import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SendMultipleEmailsButton extends StatelessWidget {
  final String email1;
  final String email2;

  const SendMultipleEmailsButton({
    super.key,
    required this.email1,
    required this.email2,
  });

  bool determineValidEmails() {
    return (email1.isNotEmpty && email2.isNotEmpty) && (email1.contains('@') && email2.contains('@'));
  }

  void openMailApp() {
    if(!determineValidEmails()) return;
    launchUrl(Uri.parse('mailto:$email1,$email2'));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openMailApp(),
      child: SizedBox(
        width: 45,
        child: Align(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Icon(Icons.email, color: (determineValidEmails() ? Colors.blue : Colors.grey), size: 28),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.group,
                    color: (determineValidEmails() ? Colors.blue : Colors.grey),
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}