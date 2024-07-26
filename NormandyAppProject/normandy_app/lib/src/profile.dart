import 'dart:io' show Platform;

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
            childAspectRatio: 1.5,
            children: <Widget>[
              GridCard(
                icon: FontAwesomeIcons.star,
                text: "Clear Favorites",
                onTap: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setStringList('favoriteContacts', []);
                  if (context.mounted) showAlertDialog(context);
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
                    Navigator.pushNamedAndRemoveUntil(
                        context, "/", (r) => false);
                  }
                },
              ),
              GridCard(
                icon: FontAwesomeIcons.file,
                text: "Clear OneDrive Cache",
                onTap: () async {
                  if (context.mounted) showCacheInstructions(context);
                },
              ),
            ]),
      ),
    );
  }
}

showCacheInstructions(BuildContext context) {
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
          child: Text("How to Clear your OneDrive Cache")),
      content: Padding(
        padding: const EdgeInsets.only(top: 0, left: 8, right: 8),
        child: Platform.isAndroid
            ? const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text("Android instructions",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("1. Open Settings"),
                    Text("2. Select Applications, then Manage Applications"),
                    Text("3. Click OneDrive"),
                    Text("4. Inside this OneDrive page:"),
                    Text("    a. Tap Force Stop"),
                    Text("    b. Tap Clear data"),
                    Text("    c. Tap Clear cache"),
                    Text("5. Uninstall OneDrive"),
                    Text("6. Re-install OneDrive from Google Play"),
                  ],
                ),
              )
            : const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text("iOS instructions",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("1. Uninstall the OneDrive app from your phone."),
                    Text("    a. Long press on the App on your Home screen."),
                    Text("    b. Tap the X, and confirm to uninstall."),
                    Text(
                        "2. Soft reset your phone by holding the Power and Home button simultaneously."),
                    Text(
                        "    a. If your phone does not have a Home button, instead press and release the Volume Up button"),
                    Text(
                        "    b. Then press and release the Volume Down button"),
                    Text(
                        "    c. Press and hold the Power button until you see the Apple logo"),
                    Text("3. Re-install OneDrive from App Store"),
                  ],
                ),
              ),
      ),
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
