import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomepageButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isDisabled;
  final bool? isGrey;
  final Function()? onTap;

  const HomepageButton({
    super.key,
    required this.text,
    required this.icon,
    required this.isDisabled,
    this.isGrey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: (isGrey ?? isDisabled) ? 0.4 : 1,
        child: Card(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Adjusted vertical padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align content to the top
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 2, top: 4),
                  child: SizedBox(
                    width: 25,
                    child: FaIcon(icon, color: const Color.fromARGB(255, 73, 73, 73)),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 73, 73, 73),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      )
    );
  }
}
