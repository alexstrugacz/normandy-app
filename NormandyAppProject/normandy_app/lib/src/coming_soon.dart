import 'package:flutter/material.dart';
import 'package:normandy_app/src/homepage_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class _Button {
  String name;
  String? route;
  IconData icon;
  bool enabled;
  _Button(this.name, this.route, this.icon, {this.enabled = false});
}

class ComingSoon extends StatelessWidget {
  final List<_Button> buttons = [
    _Button('Expense Reports', '/expense-report-selection',
        FontAwesomeIcons.addressBook,
        enabled: true),
    _Button('Projects Dashboard', null, FontAwesomeIcons.addressBook),
  ];

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
                    isDisabled: !button.enabled,
                    isGrey: true,
                    onTap: () async {
                      print(button.route);
                      print(button.name);

                      if (button.route != null) {
                        print("URL ${button.route}");
                        Navigator.pushNamed(context, button.route!);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
