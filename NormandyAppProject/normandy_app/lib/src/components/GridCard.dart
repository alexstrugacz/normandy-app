import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GridCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function()? onTap;
  GridCard({super.key, required this.text, required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
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
      ),
    );
  }
}
