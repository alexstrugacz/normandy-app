import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  final List<String> buttonNames = [
    'Contacts',
    'Active Trade',
    'Employees',
    'Expense Reports',
    'Quick Links',
    'Projects Dashboard',
    'My Profile',
  ];

  final Map<String, String> buttonRoutes = {
    'My Profile': '/profile',
    'Expense Reports': '/expense-report-selection',
    'Quick Links': '/quick-links',
    'Contacts': '/business-contacts-list',
    'Active Trade': '/select-category-page',
    'Employees': '/employee-list'
  };

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
                      // Route to the corresponding page if the route exists
                      if (buttonRoutes.containsKey(buttonNames[index])) {
                        Navigator.pushNamed(
                            context, buttonRoutes[buttonNames[index]]!);
                      } else {
                        // Handle case where the route is not defined
                        print('No route defined for ${buttonNames[index]}');
                      }
                      print('Pressed ${buttonNames[index]}');
                    },
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      buttonNames[index],
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
