import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallButton extends StatelessWidget {
  final List<String> phoneNumbers;
  final String? email;

  const CallButton({
    super.key,
    required this.phoneNumbers,
    this.email,
  });

  String determineValidPhone() {
    if (email != null && email!.isNotEmpty && RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email!)) {
      return email!;
    }
    for (var number in phoneNumbers) {
      if (number.isNotEmpty && RegExp(r'^[\+\-\.\(\)\s0-9]+$').hasMatch(number)) {
        return number;
      }
    }
    return '';
  }

  void openPhoneApp() {
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
      onTap: () => openPhoneApp(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.phone,
          size: 28,
          color: (determineValidPhone().isNotEmpty ? Colors.blue : Colors.grey),
        ),
      ),
    );
  }
}