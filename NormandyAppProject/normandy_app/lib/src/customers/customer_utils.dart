import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/customers/customer_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerUtils {

  static void showMessageBox(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void addShortcutToOneDrive(mounted, Customer? customer, BuildContext context) async {
    if (kDebugMode) {
      print("Adding shortcut to OneDrive for customer: ${customer?.id}");
    }
    if(!mounted || customer==null || customer.spUrl.isEmpty || customer.spUrl.isEmpty) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    if (userId.isEmpty) {
      if (kDebugMode) {
        print("User ID is empty. Cannot add shortcut to OneDrive.");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User ID is not available. Cannot add shortcut."),
        ),
      );
      return;
    }
    try {
      var res = await APIHelper.post(
        "customers/${customer.id}/shortcut", 
        {
          "userData": {
            "userId": userId
          }
        }, 
        context, 
        mounted
      );
      if (res != null && res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Shortcut added to OneDrive successfully."),
          ),
        );
      } else if(res != null && jsonDecode(res.body)["message"] != null) {
        String errorMessage = jsonDecode(res.body)["message"];
        if (kDebugMode) {
          print("Error adding shortcut: $errorMessage");
        }
        showMessageBox(context, "Error adding shortcut", errorMessage);
      } else {
        if (kDebugMode) {
          print("Unexpected response: ${res?.statusCode}");
        }
        showMessageBox(context, "Unkown Error (${res?.statusCode})", "Please try again later.");
      }
    } catch(error) {
      if (kDebugMode) {
        print("Error adding shortcut to OneDrive: $error");
      }
      showMessageBox(context, "Error adding shortcut", error.toString());
    }
  }

  static void launchMapUrl(Customer? customer) async { 
    String address = generateCustomerAddress(customer);

    if (address.isEmpty) {
      throw 'Address is empty. Cannot launch map.';
    }

    final Uri appleURL = Uri.parse(
    'https://maps.apple.com/?q=${Uri.encodeComponent(address)}',
    );

    final Uri googleURL = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );

    if (await canLaunchUrl(appleURL)) {
      await launchUrl(appleURL);
    } else {
      if (await canLaunchUrl(googleURL)) {
        await launchUrl(googleURL);
      } else {
        throw 'Could not launch $address';
      }
    }
  }

  static String generateCustomerAddress(Customer? customer) {
    if(customer == null) return '';
    String address = '${customer.address}, ${customer.city}, ${customer.state} ${customer.zip}';
    return address;
  }

}