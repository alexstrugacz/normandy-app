import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'components/GridCard.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Profile extends StatelessWidget {
  Profile({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.75,
          children: <Widget>[
            InkWell(
              onTap: () {},
              child: GridCard(text: "Clear Favorites", icon: FontAwesomeIcons.star),
            ),
            InkWell(
              onTap: () {},
              child: GridCard(text: "Logout", icon: FontAwesomeIcons.user),
            ),
            InkWell(
              onTap: () {},
              child: GridCard(text: "Clear OneDrive Cache", icon: FontAwesomeIcons.file),
            ),
          ]),
    );
  }
}