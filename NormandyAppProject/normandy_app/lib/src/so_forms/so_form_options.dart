import 'package:flutter/material.dart';
import 'package:normandy_app/src/quick_link_button.dart';

class SOFormOptions extends StatelessWidget {
  const SOFormOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Orders')), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 1,
          childAspectRatio: 2.3,
          children: const [
            QuickLinkButton(
              label: 'Create New Service Order',
              url: '/create-so-form',
              localLink: true
            ),
            QuickLinkButton(
              label: 'Edit Service Order',
              url: '/edit-so-form',
              localLink: true
            )
          ]
        )
      )
    );
  }
}