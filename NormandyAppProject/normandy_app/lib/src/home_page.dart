import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:normandy_app/src/components/grid_card.dart';
import 'package:normandy_app/src/homepage_button.dart';

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

  final List<IconData> buttonIcons = [
    FontAwesomeIcons.addressBook,
    FontAwesomeIcons.user,
    FontAwesomeIcons.users,
    FontAwesomeIcons.fileInvoiceDollar,
    FontAwesomeIcons.link,
    FontAwesomeIcons.chartBar,
    FontAwesomeIcons.user,
  ];

  final Map<String, String> buttonRoutes = {
    'My Profile': '/profile',
    'Expense Reports': '/expense-report-selection',
    'Quick Links': '/quick-links',
    'Contacts': '/business-contacts-list',
    'Active Trade': '/select-category-page',
    'Employees': '/employee-list'
  };

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('EEEE, MMM. d');
    return formatter.format(now);
  }

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 16),
            child: SvgPicture.asset(
              'assets/icon.svg',
              height: 80,
              width: 80,
            ),
          ),
          Padding(
            // no top padding. only left right and bottom
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              _getCurrentDate(),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            )),

          // Grid of buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 1.75,
                children: List.generate(buttonNames.length, (index) {
                  return HomepageButton(
                      icon: buttonIcons[index],
                      text: buttonNames[index],
                      onTap: () async {
                        if (buttonRoutes.containsKey(buttonNames[index])) {
                          Navigator.pushNamed(
                              context, buttonRoutes[buttonNames[index]]!);
                        }
                      }
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
