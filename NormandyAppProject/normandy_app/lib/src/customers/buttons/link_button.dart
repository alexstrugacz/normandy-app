import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkButton extends StatelessWidget {
  final String text;
  final String url;
  final IconData? icon;
  final bool? openInApp;
  final Color? overrideColor;

  const LinkButton({
    super.key,
    required this.text,
    required this.url,
    this.icon,
    this.openInApp,
    this.overrideColor,
  });

  bool isValid() {
    return (url.isNotEmpty && Uri.tryParse(url)?.hasScheme == true);
  }

  String? getOneDriveAppUrl() {
    if (!url.contains('sharepoint.com')) return null;
    final encodedUrl = Uri.encodeComponent(url);
    return 'ms-onedrive://open?url=$encodedUrl';
  }

  // opens link in the browser or app
  Future<void> openLink() async {
    if(!isValid()) return;
    final Uri uri = Uri.parse(url);
    if (openInApp == true && url.contains('sharepoint.com')) {
      final oneDriveUrl = getOneDriveAppUrl();
      if (oneDriveUrl != null) {
        final Uri oneDriveUri = Uri.parse(oneDriveUrl);
        if (await canLaunchUrl(oneDriveUri)) {
          await launchUrl(oneDriveUri, mode: LaunchMode.externalNonBrowserApplication);
          return;
        }
      }
    }
    if (await canLaunchUrl(uri)) {
      if (openInApp == true) {
        // Open in the app (if possible)
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
                color: (overrideColor ?? (isValid() ? Colors.blue : Colors.grey)),
              ),
            ),
          Text(
            text,
            style: TextStyle(
              color: (overrideColor ?? (isValid() ? Colors.blue : Colors.grey)),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
