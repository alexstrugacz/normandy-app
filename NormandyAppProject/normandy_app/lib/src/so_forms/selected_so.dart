import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/api/api_helper.dart';

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
  String? description;
  String? solution;

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

      print(data);

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

  Future<void> loadData() async {
    http.Response? response = await APIHelper.get(
      'service-orders/${widget.serviceOrderId}?isMobile=true',
      context,
      mounted
    );

    print(response);

    if (response == null) {
      return;
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)["serviceOrder"];

      print('Data: $data');

      setState(() {
        dateOfRequest = data['dateOfRequest'];
        dateClosed = data['dateClosed'];
        // dateAssigned = data['dateAssigned']; // Retrieve
        tookCall = data['tookCall'];
        // selectedServiceProvider = data['selectedServiceProvider'];
        description = data['description'];
        solution = data['solution'];
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to load data';
      });
    }
  }

  Future<void> saveData() async {

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
      description = null;
      solution = null;
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
              maxLines: 5,
              initialValue: description,
              onChanged: (value) {
                setState(() {
                });
              },
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
              initialValue: solution,
              onChanged: (value) {
                setState(() {
                });
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
              'Date Completed: ${(dateClosed != null) ? dateClosed : "(None)"}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity, // Spans the width of the screen
            child: ElevatedButton(
              onPressed: () {},
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
          )
        ]
      )
    );
  }
}