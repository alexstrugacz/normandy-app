import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:normandy_app/src/api/alert_helper.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/onedrive_shortcuts/custom_search_delegate.dart';
import 'package:normandy_app/src/onedrive_shortcuts/customer_class.dart';
import 'package:http/http.dart' as http;

class OneDriveShortcut extends StatefulWidget {
  final String mode;

  OneDriveShortcut({super.key, required this.mode}) {
    if (mode != "add" && mode != "remove") {
      throw Exception('Invalid mode');
    }
  }

  @override
  OneDriveShortcutState createState() => OneDriveShortcutState();
}
class OneDriveShortcutState extends State<OneDriveShortcut> {
  String? jwt;
  bool _loading = false;
  bool hasShortcut = false;
  String _errorMessage = '';
  Customer? selectedCustomer;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> checkIfCustomerHasShortcut(Customer customer) async {
    setState(() {
      _errorMessage = '';
      _loading = true;
    });

    http.Response? response = await APIHelper.get(
      'customers/${customer.id}/shortcut/exists?autoConnectFolder=true',
      context,
      mounted
    );

    if ((response != null) && (response.statusCode == 200)) {
      dynamic existsRaw = json.decode(response.body)['exists'];
      bool exists = (existsRaw != false && existsRaw != 'false' && existsRaw != null);

      String? nextShortcutModificationAllowedDate = json.decode(response.body)['nextShortcutModificationAllowedDate'];
      DateTime? nextDate = nextShortcutModificationAllowedDate != null ? DateTime.parse(nextShortcutModificationAllowedDate) : null;

      // Get number of minutes between now and next date
      if (nextDate != null) {
        int minutes = nextDate.difference(DateTime.now()).inMinutes;
        if (minutes > 0) {
          setState(() {
            _loading = false;
            _errorMessage = 'You can only add or remove a shortcut once every 5 minutes. Try again in $minutes minutes.';
          });
          return false;
        }
      }
    
      setState(() {
        _loading = false;
      });
      return exists;
    } else {
      try {
        if (response != null) {
        setState(() {
          _errorMessage = json.decode(response.body)['message'];
          _loading = false;
        });
        } else {
          throw Exception();
        }
      } catch (_) {
        setState(() {
          _errorMessage = 'Failed to load contacts data. Please try again later.';
          _loading = false;
        });
      }

      return false;
    }
  }


  Future<void> handleSelectCustomer(Customer customer) async {
    setState(() {
      selectedCustomer = customer;
    });
    bool setHasShortcut = await checkIfCustomerHasShortcut(customer);

    setState(() {
      hasShortcut = setHasShortcut;
    });
  }

  Future<void> handleAddShortcut(Customer customer) async {
    setState(() {
      _errorMessage = '';
      _loading = true;
    });
    
    http.Response? response = await APIHelper.post(
      'customers/${customer.id}/shortcut',
      {},
      context,
      mounted
    );

    if ((response != null) && (response.statusCode == 201)) {
      setState(() {
        _loading = false;
      });

      // Popup for success
      // Redirect to OD page
      if (mounted) {
        AlertHelper.showAlert("Shortcut added", "Shortcut added to the customer folder.", context, () {
          Navigator.pop(context);
        });
      }
    } else {
      try {
        if (response != null) {
        setState(() {
          _errorMessage = json.decode(response.body)['message'];
          _loading = false;
        });
        } else {
          throw Exception('Failed to load contacts data. Please try again later.');
        }
      } catch (_) {
        setState(() {
          _errorMessage = 'Failed to load contacts data. Please try again later.';
          _loading = false;
        });
      }
    }
  }

  Future<void> handleRemoveShortcut(Customer customer) async {
    setState(() {
      _errorMessage = '';
      _loading = true;
    });
    
    http.Response? response = await APIHelper.delete(
      'customers/${customer.id}/shortcut',
      context,
      mounted
    );

    if ((response != null) && (response.statusCode == 200)) {
      setState(() {
        _loading = false;
      });

      // Popup for success
      // Redirect to OD page
      if (mounted) {
        AlertHelper.showAlert("Shortcut removed", "Shortcut to the folder removed.", context, () {
          Navigator.pop(context);
        });
      }
    } else {
      try {
        if (response != null) {
          setState(() {
            _errorMessage = json.decode(response.body)['message'];
            _loading = false;
          });
        } else {
          throw Exception('Failed to load contacts data. Please try again later.');
        }
      } catch (_) {
        setState(() {
          _errorMessage = 'Failed to load contacts data. Please try again later.';
          _loading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mode == "add" ? "Add" : "Remove"} Shortcut'),
        actions: [
          IconButton(
              onPressed: () async {
                await showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(context: context, mounted: mounted, onSelectCustomer: handleSelectCustomer));
              },
              icon: const Icon(Icons.search))
        ]
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (selectedCustomer == null) 
              Padding(padding: const EdgeInsets.only(top: 10),
              child: 
              RichText(text: 
                TextSpan(
                  text: 'Search to ${widget.mode == "add" ? "add" : "remove"} a job shortcut.',
                  style: const TextStyle(color: Color.fromARGB(255, 78, 78, 78), fontSize: 20)
                )
              ))
            else
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        selectedCustomer != null ? selectedCustomer!.folderName : 'No customer selected',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                      )
                    ),
                    if (_loading)
                      Column(children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical:20),
                          child: Center(child: CircularProgressIndicator())
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                            onTap: () {
                              if (selectedCustomer != null) {
                                checkIfCustomerHasShortcut(selectedCustomer!);
                              }
                            },
                            child: const Text(
                              "Reload",
                              style: TextStyle(color: Colors.blue, fontSize: 16),
                            )
                        )
                      ])
                    else if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 14)
                        )
                      )
                    else if (hasShortcut && widget.mode == "add")
                      const Text("You already have a shortcut to this customer's folder.")
                    else if (hasShortcut && widget.mode == "remove")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              if (selectedCustomer != null) {
                                handleRemoveShortcut(selectedCustomer!);
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.remove, // You can choose any icon you like
                                  color: Colors.red,
                                  size: 16
                                ),
                                const SizedBox(width: 6), // Add some space between the icon and text
                                RichText(
                                  text: const TextSpan(
                                    text: 'Remove shortcut',
                                    style: TextStyle(color: Colors.red, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6)
                        ]
                      )
                    else if (hasShortcut == false && widget.mode == "add")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              "No shortcut added yet.",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16)
                            )
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () {
                              if (selectedCustomer != null) {
                                handleAddShortcut(selectedCustomer!);
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add, // You can choose any icon you like
                                  color: Colors.blue,
                                  size: 16
                                ),
                                const SizedBox(width: 6), // Add some space between the icon and text
                                RichText(
                                  text: const TextSpan(
                                    text: 'Add shortcut',
                                    style: TextStyle(color: Colors.blue, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6)
                        ]
                      )
                    else if (hasShortcut == false && widget.mode == "remove")
                      const Text("You don't have a shortcut to this customer's folder.")
                  
                  ],
                )
              )
          ]
        )
      )
    );
  }
}