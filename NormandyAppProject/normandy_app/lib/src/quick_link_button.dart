import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickLinkButton extends StatelessWidget {
  final String label;
  final String? imagePath;
  final String url;
  final bool localLink;

  const QuickLinkButton(
      {super.key, required this.label, this.imagePath, required this.url, required this.localLink});

  Future<void> _launchURL(
    BuildContext context
  ) async {
    if (localLink) {
      Navigator.pushNamed(context, url);
      return;
    } else {
      if (!await launchUrl(Uri.parse(url))) {
        // ignore: use_build_context_synchronously
        showAlertDialog(context);
      }
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
        title: const Padding(
            padding: EdgeInsets.only(top: 8, left: 8, right: 8),
            child: Text("Couldn't open app")),
        content: const Padding(
            padding: EdgeInsets.only(top: 0, left: 8, right: 8),
            child: Text("Make sure the app is downloaded.")),
        actions: [
          okButton,
        ]);

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchURL(context);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(imagePath!, height: 70, width: 70)
            else

            const SizedBox(height: 6),

            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center
            ),
          ],
        ),
      ),
    );
  }
}
