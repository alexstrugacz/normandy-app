import 'package:flutter/material.dart';
import 'package:normandy_app/src/active_trades/active_trades_categories.dart';
import 'package:normandy_app/src/business_contacts/business_contacts_list.dart';
import 'package:normandy_app/src/direct_phone_numbers/direct_phone_list.dart';
import 'package:normandy_app/src/choose_image.dart';
import 'package:normandy_app/src/home_page.dart';
import 'package:normandy_app/src/login_page.dart';
import 'package:normandy_app/src/contacts.dart';
import 'package:normandy_app/src/expense_reports.dart';
import 'package:normandy_app/src/onedrive_shortcuts/onedrive_shortcut_actions.dart';
import 'package:normandy_app/src/onedrive_shortcuts/onedrive_shortcuts.dart';
import 'package:normandy_app/src/superintendents/superintendents_list.dart';
import 'package:normandy_app/src/take_a_photo.dart';
import 'package:normandy_app/src/currently_stored.dart';
import 'profile.dart';
import 'package:normandy_app/src/quick_link_screen.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Demo Login App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
        ),
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
        routes: {
          "/home": (context) => HomePage(),
          "/business-contacts-list": (context) => BusinessContactsList(),
          "/contacts": (context) => const Contacts(),
          "/profile": (context) => const Profile(),
          "/quick-links": (context) => const QuickLinksScreen(),
          "/select-category-page": (context) => const SelectCategoryPage(),
          "/employee-list": (context) => BusinessContactsList(isEmployee: true),
          "/favorites": (context) => BusinessContactsList(isFavorite: true),
          "/projects-dashboard": (context) => const Text("Coming soon..."),
          '/expense-report-selection': (context) =>
              ExpenseReports(header: 'Expense Reports'),
          '/expense-report-take-a-photo': (context) =>
              const TakeAPhoto(header: 'Take a Photo'),
          '/expense-report-currently-stored': (context) =>
              const CurrentlyStored(header: 'Currently Stored'),
          '/expense-report-choose-image': (context) =>
              const ChooseImage(header: 'Choose Image'),
          "/onedrive-shortcuts": (context) => const OnedriveShortcutActions(),
          "/add-onedrive-shortcut": (context) => OneDriveShortcut(mode: "add"),
          "/remove-onedrive-shortcut": (context) => OneDriveShortcut(mode: "remove"),
          "/clear-onedrive-cache": (context) => ClearOnedriveCache(),
          '/direct-phone-list': (context) => const DirectPhoneList(),
          '/superintendent-list': (context) => const SuperintendentsList(),
        });
  }
}
