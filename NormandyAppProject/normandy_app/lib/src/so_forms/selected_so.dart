import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/api/alert_helper.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:flutter/foundation.dart';

class SelectedSOForm extends StatefulWidget {
  final String serviceOrderId;

  const SelectedSOForm({super.key, required this.serviceOrderId});

  @override
  SelectedSOFormState createState() => SelectedSOFormState();
}

class SelectedSOFormState extends State<SelectedSOForm> {
  String? dateOfRequest;
  String? dateClosed;
  String? dateAssigned;
  String? tookCall;

  String? selectedServiceProvider;
  // String? description;
  // String? solution;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _solutionController = TextEditingController();

  List<DropdownMenuItem<String>> _serviceProviders = [];

  String _errorMessage = "";
  bool _loading = false;

  Future<void> loadServiceProviders() async {
    setState(() {
      _errorMessage = '';
      _loading = true;
    });

    http.Response? response = await APIHelper.get(
      'service-handlers',
      context,
      mounted
    );

    if ((response != null) && (response.statusCode == 200)) {
      List<dynamic> data = json.decode(response.body)['serviceHandlers'];

      if(kDebugMode) print(data);

      List<DropdownMenuItem<String>> serviceProviders = [];

      for (var serviceProvider in data) {
        serviceProviders.add(DropdownMenuItem<String>(
          value: serviceProvider['_id'],
          child: Text(
            serviceProvider['name'],       
            style: const TextStyle(fontSize: 12)
          ),
        ));
      }

      setState(() {
        _serviceProviders = serviceProviders;
        _loading = false;
      });
    } else {
      setState(() {
        _errorMessage = 'An error occurred while fetching projects. Please try again.';
        _loading = false;
      });
    }

  }

  String? _convertToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List && value.isNotEmpty) return value.first.toString();
    if (value is List) return null;
    return value.toString();
  }

  Future<void> loadData() async {
    http.Response? response = await APIHelper.get(
      'service-orders/${widget.serviceOrderId}?isMobile=true',
      context,
      mounted
    );

    if(kDebugMode) print(response);

    if (response == null) {
      return;
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)["serviceOrder"];

      if(kDebugMode) print('Data: $data');

      if(kDebugMode) print("Solution: ${data['solution']}");

      setState(() {
        dateOfRequest = _convertToString(data['dateOfRequest']);
        dateClosed = _convertToString(data['dateClosed']);
        // dateAssigned = data['dateAssigned']; // Retrieve
        tookCall = _convertToString(data['tookCall']);
        selectedServiceProvider = _convertToString(data['serviceHandler']);
        // description = data['description'];
        // solution = data['solution'];
      });

      if (data['description'] != null) {
        _descriptionController.text = data['description'] ?? '';
      }
      if (data['solution'] != null) {
        _solutionController.text = data['solution'] ?? '';      
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to load data';
      });
    }
  }

  Future<void> saveData() async {
    if (selectedServiceProvider == null) return;

    setState(() {
      _errorMessage = '';
      _loading = true;
    });
    
    Map<String, dynamic> requestBody = {
      "isMobile": true
    };

    requestBody['description'] = _descriptionController.text;
    requestBody['solution'] = _solutionController.text;

    if (selectedServiceProvider != null) {
      requestBody['singleServiceHandlerId'] = selectedServiceProvider;
    }

    if(kDebugMode) print("Request Body: $requestBody");
    
    http.Response? response = await APIHelper.put(
      'service-orders/${widget.serviceOrderId}',
      requestBody,
      context,
      mounted
    );

    if ((response != null) && (response.statusCode == 200)) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        AlertHelper.showAlert("Service Order edits saved", "The service order edits have been saved.", context, () {
          Navigator.pop(context);
        });
      }
    } else {
      if(kDebugMode) print(response?.body);
      if(kDebugMode) print(response?.statusCode);
      setState(() {
        _errorMessage = 'An error occurred while saving data. Please try again.';
        _loading = false;
      });
    }
  }


  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _descriptionController.dispose();
    _solutionController.dispose();

    super.dispose();
  }


  @override
  void didUpdateWidget(covariant SelectedSOForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serviceOrderId != widget.serviceOrderId) {
      loadData(); // Reload data when serviceOrderId changes
      // Reset  all fields

      dateOfRequest = null;
      dateClosed = null;
      dateAssigned = null;
      tookCall = null;

      selectedServiceProvider = null;
      _descriptionController.text = "";
      _solutionController.text = "";
    }
  }


  @override
  void initState() {
    super.initState();
    loadData();
    loadServiceProviders();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container( 
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(4.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loading) 
            const Column(children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical:20),
                child: Center(child: CircularProgressIndicator())
              ),
              SizedBox(height: 6)
            ])
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 5),
                if (dateOfRequest != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Date of Request: $dateOfRequest',//${DateFormat.yMMMd().format(dateOfRequest)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                if (tookCall != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Took Call: $tookCall',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                // Problem Description
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Problem Description',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 14)
                    ),
                    style: const TextStyle(fontSize: 12),
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    maxLines: 5,
                    controller: _solutionController,
                    onChanged: (value) {
                      if (dateClosed == null) {
                        if (value.isNotEmpty) {
                          // Current date
                          final DateTime now = DateTime.now();
                          final String formattedDate = '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
                          setState(() {
                            dateClosed = formattedDate;
                          });
                        } else {
                          setState(() {
                            dateClosed = null;
                          });
                        }
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Problem Solution',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 14)
                    ),
                    style: const TextStyle(fontSize: 12),
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                // Service Provider Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: selectedServiceProvider,
                    onChanged: (value) {
                      setState(() {
                        selectedServiceProvider = value;
                      });
                    },
                    items: _serviceProviders,
                    decoration: const InputDecoration(
                      labelText: 'Select Service Provider',
                      labelStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 12, color: Colors.black)
                  ),
                ),
                if (dateAssigned != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Date Assigned: $dateAssigned',//${DateFormat.yMMMd().format(dateOfRequest)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                Padding(
                  padding:const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Date Closed: ${(dateClosed != null) ? dateClosed : "(None)"}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity, // Spans the width of the screen
                  child: ElevatedButton(
                    onPressed: saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Solid blue background
                      padding: const EdgeInsets.symmetric(vertical: 16), // Increase button height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // No rounded corners
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white, // White text color
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14)
                  )
                )
              ]
            )
        ]
      )
    );
  }
}