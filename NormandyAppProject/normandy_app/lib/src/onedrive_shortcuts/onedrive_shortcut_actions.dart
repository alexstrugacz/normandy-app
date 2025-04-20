import 'package:flutter/material.dart';
import 'package:normandy_app/src/quick_link_button.dart';

class OnedriveShortcutActions extends StatelessWidget {
  const OnedriveShortcutActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OneDrive Shortcuts')), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 1,
          childAspectRatio: 2.3,
          children: const [
            QuickLinkButton(
              label: 'Go to My OneDrive',
              url: 'ms-sharepoint://?starturl=https://ndbrcloudcom-my.sharepoint.com/my',
              localLink: false
            ),
            QuickLinkButton(
              label: 'Add Shortcut',
              url: '/add-onedrive-shortcut',
              localLink: true
            ),
            QuickLinkButton(
              label: 'Remove Shortcuts',
              url: '/remove-onedrive-shortcut',
              localLink: true
            ),
            QuickLinkButton(
              label: 'Clear OneDrive Cache',
              url: '/clear-onedrive-cache',
              localLink: true
            ),
          ]
        )
      )
    );
  }
}