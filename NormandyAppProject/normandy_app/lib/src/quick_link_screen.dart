import 'package:flutter/material.dart';
import 'package:normandy_app/src/quick_link_button.dart';

class QuickLinksScreen extends StatelessWidget {
  const QuickLinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Links')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: const [
            QuickLinkButton(
              label: 'Teams',
              imagePath: 'assets/images/teams.png',
              url: 'msteams://',
              localLink: false
            ),
            QuickLinkButton(
              label: 'Outlook',
              imagePath: 'assets/images/outlook.png',
              url: 'ms-outlook://',
              localLink: false
            ),
            QuickLinkButton(
              label: 'OneDrive',
              imagePath: 'assets/images/oneDrive.png',
              url: 'ms-onedrive://',
              localLink: false
            ),
            QuickLinkButton(
              label: 'OneDrive Shortcuts',
              imagePath: 'assets/images/oneDrive.png',
              url: '/onedrive-shortcuts',
              localLink: true
            ),
            QuickLinkButton(
              label: 'Home Depot',
              imagePath: 'assets/images/homeDepot.png',
              url: 'homedepot://',
              localLink: false
            ),
            QuickLinkButton(
              label: 'Menards',
              imagePath: 'assets/images/menards.png',
              url: 'menardsmobile://',
              localLink: false
            ),
            QuickLinkButton(
              label: 'Hines',
              imagePath: 'assets/images/hines.png',
              url: 'https://www.hinessupply.com',
              localLink: false
            ),
            QuickLinkButton(
              label: 'Google Translate',
              imagePath: 'assets/images/googleTranslate.png',
              url: 'googletranslate://',
              localLink: false
            ),
            QuickLinkButton(
              label: 'Time Squared',
              imagePath: 'assets/images/timeSquared.png',
              url: 'timesquared://',
              localLink: false
            ),
            QuickLinkButton(
              label: 'Mileage',
              imagePath: 'assets/images/mileage.png',
              url: 'mileiq://',
              localLink: false
            ),
          ],
        ),
      ),
    );
  }
}