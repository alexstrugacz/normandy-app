import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:normandy_app/src/homepage_button.dart';

class _Button {
  String name;
  String route;
  IconData icon;
  _Button(this.name, this.route, this.icon);
}

class HomePage extends StatelessWidget {
  final List<_Button> buttons = [
    _Button('Contacts', '/contacts', FontAwesomeIcons.addressBook),
    _Button(
        'Upload Image', '/client-choose-image-page', FontAwesomeIcons.upload),
    _Button('Quick Links', '/quick-links', FontAwesomeIcons.link),
    _Button('Service Orders', '/so-forms', FontAwesomeIcons.fileInvoiceDollar),
    _Button('My Profile', '/profile', FontAwesomeIcons.user),
    _Button('Coming Soon', '/coming-soon', FontAwesomeIcons.clock),
  ];

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('EEEE, MMM. d');
    return formatter.format(now);
  }

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        toolbarHeight: 40,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 4),
            child: SvgPicture.asset(
              'assets/icon.svg',
              height: 80,
              width: 80,
            ),
          ),
          Padding(
              // no top padding. only left right and bottom
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
              child: Text(
                _getCurrentDate(),
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              )),
          // Grid of buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
                children: buttons.map((button) {
                  return HomepageButton(
                      icon: button.icon,
                      text: button.name,
                      isDisabled: false,
                      onTap: () async {
                        print(button.route);
                        print(button.name);

                        print("URL ${button.route}");
                        Navigator.pushNamed(context, button.route);
                      });
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
