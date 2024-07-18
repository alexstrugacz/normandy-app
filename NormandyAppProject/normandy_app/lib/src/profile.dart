import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setStringList('favoriteContacts', []);
                showAlertDialog(context);
              },
            ),
            GridCard(
              icon: FontAwesomeIcons.user,
              text: "Logout",
              onTap: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.remove('jwt');
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
                }
              },
            ),
            GridCard(
              icon: FontAwesomeIcons.file,
              text: "Clear OneDrive Cache",
              onTap: () async {
                // The Cache is local? Because of App sandboxing, I am not sure if we can do this directly.
                // TODO link to the appropriate page in the Settings app, so users can clear it there.
                String url =
                    (Theme.of(context).platform == TargetPlatform.android)
                        ? 'package:com.microsoft.skydrive'
                        : 'app-settings:';
                await launchUrlString(url);
              },
            ),
          ]),
    );
  }
}

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
      title: const Padding(
          padding: EdgeInsets.only(top: 8, left: 8, right: 8),
          child: Text("Favorites cleared")),
      content: const Padding(
          padding: EdgeInsets.only(top: 0, left: 8, right: 8),
          child: Text("Your favorites have been cleared.")),
      actions: [
        okButton,
      ]);

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
