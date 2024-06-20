import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GridCard extends StatelessWidget {
  final String text;
  final IconData icon;
  GridCard({super.key, required this.text, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 25,
              child: FaIcon(icon),
            ),
            const SizedBox(width: 12),
            Flexible(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
