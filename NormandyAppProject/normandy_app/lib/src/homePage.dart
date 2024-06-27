import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  final List<String> buttonNames = [
    'Contacts',
    'Expense Reports',
    'Quick Links',
    'Projects Dashboard',
    'My Profile',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('HomePage'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset(
                'assets/icon.svg',
                height: 80,
                width: 80,
              ),
            ),
            // Header
            const Text(
              'Mon. Aug 17',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Text('My Profile')),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/quick-links');
              },
              child: Text('Go to Quick Links'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/business-contacts-list');
              },
              child: Text('Business Contacts'),
            ),
            // Grid of buttons
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: List.generate(buttonNames.length, (index) {
                  return ElevatedButton(
                    onPressed: () {
                      //Route to the corresponding page

                      print('Pressed ${buttonNames[index]}');
                    },
                    style: ElevatedButton.styleFrom(
                      // Align text to top-left of button
                      alignment: Alignment.topLeft,
                      // Add padding for better alignment
                      padding: EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      buttonNames[index],
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ), // Display actual name
                  );
                }),
              ),
            )),
          ],
        ));
  }
}
