
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/onedrive_shortcuts/custom_search_delegate.dart';
import 'package:normandy_app/src/onedrive_shortcuts/customer_class.dart';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/so_forms/selected_so.dart';

class DropdownOption {
  String id;
  String text;

  DropdownOption({
    required this.id,
    required this.text
  });
}

class EditSOForm extends StatefulWidget {
  const EditSOForm({super.key});

  @override
  EditSOFormState createState() => EditSOFormState();
}

class EditSOFormState extends State<EditSOForm> {
  String? jwt;
  Customer? selectedCustomer;
  String? selectedProject;
  String? selectedServiceOrder;

  List<DropdownMenuItem<String>> _projects = [];
  List<DropdownMenuItem<String>> _serviceOrders = [];

  bool _loading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadProjects() async {
    // Implement your API call here to fetch projects
    if (selectedCustomer?.id != null) {
      setState(() {
        _errorMessage = '';
        selectedServiceOrder = null;
        _loading = true;
      });

      http.Response? response = await APIHelper.get(
        'projects?customerId=${selectedCustomer?.id}&includeProjectName=true',
        context,
        mounted
      );

      if ((response != null) && (response.statusCode == 200)) {
        List<dynamic> data = json.decode(response.body)['projects'];
        List<DropdownMenuItem<String>> projects = [];
        Map<String, String> projectsMap = {};

        for (var project in data) {
          projects.add(DropdownMenuItem<String>(
            value: project['_id'],
            child: Text(
              project['projectName'],       
              style: const TextStyle(fontSize: 12)
            ),
          ));
          projectsMap[project['projectName']] = project['_id'];
        }

        setState(() {
          _projects = projects;
          selectedServiceOrder = null;
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'An error occurred while fetching projects. Please try again.';
          selectedServiceOrder = null;
          _loading = false;
        });
      }
    }
  }

  Future<void> handleLoadServiceOrders() async {
    // Retrieve and list service orders

    if (selectedProject == null) return;

    setState(() {
      _errorMessage = ''; 
      selectedServiceOrder = null;
      _loading = true;
    });

    http.Response? response = await APIHelper.get(
      'service-orders?projectId=$selectedProject&isMobile=true',
      context,
      mounted
    );
    if ((response != null) && (response.statusCode == 200)) {
      List<dynamic> data = json.decode(response.body)['serviceOrders'];
      List<DropdownMenuItem<String>> serviceOrders = [];

      for (var serviceOrder in data) {
        serviceOrders.add(DropdownMenuItem<String>(
          value: serviceOrder['_id'],
          child: Text(
            serviceOrder['optionName'],
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis
          )
        ));
      }
      setState(() {
        _serviceOrders = serviceOrders;
        selectedServiceOrder = null;
        _loading = false;
      });
    } else {
      setState(() {
        _errorMessage = 'An error occurred while fetching service orders. Please try again.';
        selectedServiceOrder = null;
        _loading = false;
      });

    }
  }

  Future<void> handleSelectCustomer(Customer customer) async {
    setState(() {
      selectedCustomer = customer;
    });
    loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Service Order',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(context: context, mounted: mounted, onSelectCustomer: handleSelectCustomer)
                );
              },
              icon: const Icon(Icons.search))
        ]
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (selectedCustomer == null) 
                Padding(padding: const EdgeInsets.only(top: 10),
                child: 
                RichText(text: 
                  const TextSpan(
                    text: 'Search to select a customer.',
                    style: TextStyle(color: Color.fromARGB(255, 78, 78, 78), fontSize: 20)
                  )
                ))
              else if (_loading)
                const Column(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical:20),
                    child: Center(child: CircularProgressIndicator())
                  ),
                  SizedBox(height: 6)
                ])
              else
                Container( 
                  margin: const EdgeInsets.only(top: 0),
                  padding: const EdgeInsets.all(4.0),
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
                            // Project Dropdown
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: DropdownButtonFormField<String>(
                                value: selectedProject,
                                isExpanded: true,
                                onChanged: (value) {
                                  setState(() {
                                    selectedProject = value;
                                  });
                                  handleLoadServiceOrders();
                                },
                                items: _projects,
                                decoration: const InputDecoration(
                                  labelText: 'Select Project',
                                  labelStyle: TextStyle(fontSize: 14),
                                  border: OutlineInputBorder(),
                                )
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Select Service Order
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: DropdownButtonFormField<String>(
                                value: selectedServiceOrder,
                                isExpanded: true,
                                onChanged: (value) {
                                  setState(() {
                                    selectedServiceOrder = value;
                                  });
                                },
                                items: _serviceOrders,
                                decoration: const InputDecoration(
                                  labelText: 'Select Service Order',
                                  labelStyle: TextStyle(fontSize: 14),
                                  border: OutlineInputBorder(),
                                )
                              ),
                            ),
                            
                            if (selectedServiceOrder != null)
                              SelectedSOForm(serviceOrderId: selectedServiceOrder!),
                            
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red, fontSize: 14)
                              )
                            )
                          ],
                        )
                    ]
                  )
                )
            ]
          )
        )
      )
    );
  }
}



