import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'components/grid_card.dart';

class Contacts extends StatelessWidget {
  const Contacts({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
            childAspectRatio: 1.5,
            children: <Widget>[
              GridCard(
                icon: FontAwesomeIcons.phone,
                text: "Direct Phone Numbers",
                onTap: () async {},
              ),
              GridCard(
                icon: FontAwesomeIcons.pencil,
                text: "Superintendents",
                onTap: () async {},
              ),
              GridCard(
                icon: FontAwesomeIcons.suitcase,
                text: "Business Contacts",
                onTap: () async {
                  Navigator.pushNamed(context, "/business-contacts-list");
                },
              ),
              GridCard(
                icon: FontAwesomeIcons.user,
                text: "Employees",
                onTap: () async {
                  Navigator.pushNamed(context, "/business-contacts-list");
                },
              ),
              GridCard(
                icon: FontAwesomeIcons.suitcase,
                text: "Active Trades",
                onTap: () async {},
              ),
              GridCard(
                icon: FontAwesomeIcons.star,
                text: "Favorites",
                onTap: () async {
                  Navigator.pushNamed(context, "/favorites");
                },
              ),
            ]),
      ),
    );
  }
}
