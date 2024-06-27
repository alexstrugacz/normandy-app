import 'package:flutter/material.dart';
import 'package:normandy_app/src/DemoPage1.dart';
import 'package:normandy_app/src/DemoPage2.dart';
import 'package:normandy_app/src/business_contacts/businessContactsList.dart';
import 'package:normandy_app/src/homePage.dart';
import 'package:normandy_app/src/loginPage.dart';
import 'package:normandy_app/src/expenseReports.dart';
import 'package:normandy_app/src/takeAPhoto.dart';
import 'package:normandy_app/src/currentlyStored.dart';
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
          fontFamily: 'Roboto',
        ),
        home: LoginPage(),
        routes: {
          "/home": (context) => HomePage(),
          "/business-contacts-list": (context) => BusinessContactsList(),
          "/profile": (context) => Profile(),
          "/demo-page-1": (context) => DemoPage1(),
          "/demo-page-2": (context) => DemoPage2(),
          "/quick-links": (context) => QuickLinksScreen(),
          "/projects-dashboard": (context) => DemoPage1(),
          '/expense-report-selection': (context) =>
              ExpenseReports(header: 'Expense Reports'),
          '/expense-report-take-a-photo': (context) =>
              TakeAPhoto(header: 'Take a Photo'),
          '/expense-report-currently-stored': (context) =>
              CurrentlyStored(header: 'Currently Stored'),
        });
  }
}
