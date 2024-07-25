
import 'package:flutter/material.dart';

class AlertHelper {
  static showAlert(String title, String content, BuildContext context, Function? onPressed) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () { 
        Navigator.of(context).pop();
        if (onPressed != null) {
          onPressed();
        }
      }
    );

    AlertDialog alert = AlertDialog(
      title: Padding(padding: const EdgeInsets.only(top: 8, left: 8, right: 8), child: Text(title)),
      content: Padding(padding: const EdgeInsets.only(top: 0, left: 8, right: 8), child: Text(content)),
      actions: [
        okButton,
      ]
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
