import 'package:flutter/material.dart';
import 'package:normandy_app/src/DemoPage1.dart';
import 'package:normandy_app/src/DemoPage2.dart';
import 'package:normandy_app/src/business_contacts/businessContactsList.dart';
import 'package:normandy_app/src/homePage.dart';
import 'package:normandy_app/src/loginPage.dart';
import 'profile.dart';
import 'package:normandy_app/src/quickLinkScreen.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Demo Login App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginPage(),
        routes: {
          "/home": (context) => HomePage(),
          "/business-contacts-list": (context) => BusinessContactsList(),
          "/profile": (context) => Profile(),
          "/demo-page-1": (context) => DemoPage1(),
          "/demo-page-2": (context) => DemoPage2(),
          "/quick-links": (context) => QuickLinksScreen(),
        });
  }
}
