import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/grid_card.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});
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
            GridCard(
              icon: FontAwesomeIcons.star,
              text: "Clear Favorites",
              onTap: () async {
                // assume we are storing in SharedPreferences for now
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                // await prefs.setStringList('favorites', <String>[/* favorite id's */]);
                await prefs.remove('favorites');
              },
            ),
            GridCard(
              icon: FontAwesomeIcons.user,
              text: "Logout",
              onTap: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                // await prefs.setString('authtoken', '<jwt>');
                await prefs.remove('authtoken');
                if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
              },
            ),
            GridCard(
              icon: FontAwesomeIcons.file,
              text: "Clear OneDrive Cache",
              onTap: () {
                // The Cache is local? Because of App sandboxing, I am not sure if we can do this directly.
                // TODO link to the appropriate page in the Settings app, so users can clear it there.
              },
            ),
          ]),
    );
  }
}
