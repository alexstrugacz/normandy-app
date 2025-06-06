import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SendMessageButton extends StatelessWidget {
  final List<String> phoneNumbers;
  final String? email;

  const SendMessageButton({
    super.key,
    required this.phoneNumbers,
    this.email,
  });

  String determineValidPhone() {
    if (email != null && email!.isNotEmpty && RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email!)) {
      return email!;
    }
    for (var number in phoneNumbers) {
      if (number.isNotEmpty && RegExp(r'^\+?[0-9\s]+$').hasMatch(number)) {
        return number;
      }
    }
    return '';
  }

  void openMessageApp() {
    String validNumber = determineValidPhone();
    if(validNumber.isEmpty) return;

    if(email != null && email!.isNotEmpty) {
      launchUrl(Uri.parse('msteams:/l/call/0/0?users=$email'));
      return;
    }
    
    launchUrl(Uri.parse('tel:$validNumber'));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openMessageApp(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.message,
          size: 28,
          color: (determineValidPhone().isNotEmpty ? Colors.blue : Colors.grey),
        ),
      ),
    );
  }
}