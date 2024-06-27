import 'package:flutter/material.dart';
import 'package:normandy_app/src/quickLinkButton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuickLinksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Links')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            QuickLinkButton(
              label: 'Teams',
              imagePath: 'assets/images/teams.png',
              url: 'https://teams.microsoft.com',
            ),
            QuickLinkButton(
              label: 'Outlook',
              imagePath: 'assets/images/outlook.png',
              url: 'https://outlook.office.com',
            ),
            QuickLinkButton(
              label: 'OneDrive',
              imagePath: 'assets/images/oneDrive.png',
              url: 'https://onedrive.live.com',
            ),
            QuickLinkButton(
              label: 'Home Depot',
              imagePath: 'assets/images/homeDepot.png',
              url: 'https://www.homedepot.com',
            ),
            QuickLinkButton(
              label: 'Menards',
              imagePath: 'assets/images/menards.png',
              url: 'https://www.menards.com',
            ),
            QuickLinkButton(
              label: 'Hines',
              imagePath: 'assets/images/hines.png',
              url: 'https://www.hines.com',
            ),
            QuickLinkButton(
              label: 'Google Translate',
              imagePath: 'assets/images/googleTranslate.png',
              url: 'https://translate.google.com',
            ),
            QuickLinkButton(
              label: 'Time Squared',
              imagePath: 'assets/images/timeSquared.png',
              url: 'https://timesquared.com',
            ),
            QuickLinkButton(
              label: 'Mileage',
              imagePath: 'assets/images/mileage.png',
              url: 'https://www.mileage.com',
            ),
          ],
        ),
      ),
    );
  }
}
