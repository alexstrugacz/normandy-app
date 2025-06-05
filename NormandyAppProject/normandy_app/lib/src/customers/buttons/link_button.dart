import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkButton extends StatelessWidget {
  final String text;
  final String url;
  final IconData? icon;
  final bool? openInApp;

  const LinkButton({
    super.key,
    required this.text,
    required this.url,
    this.icon,
    this.openInApp,
  });

  bool isValid() {
    return (url.isNotEmpty && Uri.tryParse(url)?.hasScheme == true);
  }

  // opens link in the browser or app
  Future<void> openLink() async {
    if(!isValid()) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      if (openInApp == true) {
        // Open in the app
        await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      } else {
        // Open in the browser
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => openLink(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(
                icon,
                size: 16,
                color: (isValid() ? Colors.blue : Colors.grey),
              ),
            ),
          Text(
            text,
            style: TextStyle(
              color: (isValid() ? Colors.blue : Colors.grey),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
