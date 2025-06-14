import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/api/alert_helper.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/customers/customer_type.dart';
import 'package:normandy_app/src/onedrive_shortcuts/custom_search_delegate.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CreateSOForm extends StatefulWidget {
  final Customer? customer;

  const CreateSOForm({super.key, this.customer});

  @override
  CreateSOFormState createState() => CreateSOFormState();
}

class CreateSOFormState extends State<CreateSOForm> {
  String? jwt;
  Customer? selectedCustomer;
  String? selectedProject;
  String? selectedServiceProvider;
  String? newCellPhone;
  int ownerWhoCalled = 1;
  bool canShowSearch = true;
  String problemDescription = '';
  DateTime dateOfRequest = DateTime.now();
  DateTime dateAssigned = DateTime.now();

  List<DropdownMenuItem<String>> _projects = [];
  List<DropdownMenuItem<String>> _serviceProviders = [];

  bool _loading = false;
  String _errorMessage = '';

  bool hasNumber() {
    return ownerWhoCalled == 1 &&
            (selectedCustomer?.cellPhone1.isNotEmpty ?? false) ||
        ownerWhoCalled == 2 &&
            (selectedCustomer?.cellPhone2.isNotEmpty ?? false);
  }

  String cellPhoneRepr(String s) {
    if (s.isEmpty) {
      return 'No cell on file';
    } else {
      return s;
    }
  }

  @override
  void initState() {
    super.initState();
    selectedServiceProvider = "64fbd743fe8f92f08172b11a"; // Kenney Kozik

    if (widget.customer != null) {
      handleSelectCustomer(widget.customer as Customer);
      canShowSearch = false;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSearch(
            context: context,
            delegate: CustomSearchDelegate(
                context: context,
                mounted: mounted,
                onSelectCustomer: handleSelectCustomer));
      });
    }
  }

  Future<void> handleSelectCustomer(Customer customer) async {
    setState(() {
      _loading = true;
    });
    http.Response? response =
        await APIHelper.get('customers/${customer.id}', context, mounted);

    if ((response == null) || response.statusCode != 200) {
      return;
    }
    setState(() {
      selectedCustomer =
          Customer.fromJson(json.decode(response.body)['customer']);
      if ((selectedCustomer?.cellPhone1.isEmpty ?? true) &&
          (selectedCustomer?.cellPhone2.isNotEmpty ?? false)) {
        ownerWhoCalled = 2;
      } else {
        ownerWhoCalled = 1;
      }
    });
    loadProjects();
    setState(() {
      _loading = false;
    });
  }

  Future<void> loadServiceProviders() async {
    // Implement your API call here to fetch service providers
    setState(() {
      _errorMessage = '';
      _loading = true;
    });

    http.Response? response =
        await APIHelper.get('service-handlers', context, mounted);

    if ((response != null) && (response.statusCode == 200)) {
      List<dynamic> data = json.decode(response.body)['serviceHandlers'];

      if (kDebugMode) print(data);

      List<DropdownMenuItem<String>> serviceProviders = [];

      for (var serviceProvider in data) {
        serviceProviders.add(DropdownMenuItem<String>(
          value: serviceProvider['_id'],
          child: Text(serviceProvider['name'],
              style: const TextStyle(fontSize: 12)),
        ));
      }

      setState(() {
        _serviceProviders = serviceProviders;
        _loading = false;
      });
    } else {
      setState(() {
        _errorMessage =
            'An error occurred while fetching projects. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> loadProjects() async {
    // Implement your API call here to fetch projects
    loadServiceProviders();

    if (selectedCustomer?.id != null) {
      setState(() {
        _errorMessage = '';
        _loading = true;
      });

      http.Response? response = await APIHelper.get(
          'projects?customerId=${selectedCustomer?.id}&includeProjectName=true',
          context,
          mounted);

      if ((response != null) && (response.statusCode == 200)) {
        List<dynamic> data = json.decode(response.body)['projects'];
        List<DropdownMenuItem<String>> projects = [];

        for (var project in data) {
          projects.add(DropdownMenuItem<String>(
            value: project['_id'],
            child: Text(project['projectName'],
                style: const TextStyle(fontSize: 12)),
          ));
        }

        setState(() {
          _projects = projects;
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'An error occurred while fetching projects. Please try again.';
          _loading = false;
        });
      }
    }
  }

  Future<void> createServiceOrder() async {
    setState(() {
      _loading = true;
    });

    if (selectedProject == null) {
      setState(() {
        _errorMessage = 'Please select a project.';
        _loading = false;
      });
      return;
    }

    if (selectedServiceProvider == null) {
      setState(() {
        _errorMessage = 'Please select a service provider.';
        _loading = false;
      });
      return;
    }

    if (problemDescription.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a problem description.';
        _loading = false;
      });
      return;
    }

    if (selectedProject == null) {
      setState(() {
        _errorMessage =
            'An error occurred while creating the service order. Please try again.';
        _loading = false;
      });
      return;
    }

    if (selectedServiceProvider == null) {
      setState(() {
        _errorMessage =
            'An error occurred while creating the service order. Please try again.';
        _loading = false;
      });
      return;
    }

    if (kDebugMode) print("Initiate request.");

    Map<String, dynamic> body = {
      "projectId": selectedProject,
      "dateOfRequest": dateOfRequest.toIso8601String(),
      "description": problemDescription,
      "serviceHandler": [
        {
          "id": selectedServiceProvider,
          "customOptionMode": false,
          "dateAssigned": dateOfRequest.toIso8601String()
        }
      ],
    };
    if (newCellPhone != null) {
      if (ownerWhoCalled == 1) {
        body['newCellPhone1'] = newCellPhone;
      } else {
        body['newCellPhone2'] = newCellPhone;
      }
    }

    if (kDebugMode) print("Request body: $body");

    http.Response? response =
        await APIHelper.post("service-orders", body, context, mounted);

    if (kDebugMode) print("Response received.");

    if ((response != null) && (response.statusCode == 201)) {
      // Service order created successfully
      if (mounted) {
        AlertHelper.showAlert("Created Service Order",
            "Service order successfully created.", context, () {
          Navigator.pop(context);
        });
      }
    } else {
      // Error creating service order
      // Display error message
      if (kDebugMode) print("Error Message ${response?.body}");

      setState(() {
        _errorMessage =
            'An error occurred while creating the service order. Please try again.';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading == true) {
      return const Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
        appBar: AppBar(
            title: Text(
                (selectedCustomer == null)
                    ? 'Create New Service Order'
                    : 'Create New Service Order for ${((ownerWhoCalled == 1) ? "${selectedCustomer?.fname1} ${selectedCustomer?.lname1}" : "${selectedCustomer?.fname2} ${selectedCustomer?.lname2}").trim()}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            actions: [
              canShowSearch
                  ? (IconButton(
                      onPressed: () async {
                        await showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(
                                context: context,
                                mounted: mounted,
                                onSelectCustomer: handleSelectCustomer));
                      },
                      icon: const Icon(Icons.search)))
                  : Text("")
            ]),
        body: SingleChildScrollView(
            // Wrap the body in SingleChildScrollView
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (selectedCustomer == null)
                    ListTile(title: Text('Start typing to search'))
                  else
                    Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.only(
                            left: 4, right: 4, top: 4, bottom: 20),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                      selectedCustomer != null
                                          ? selectedCustomer!.folderName
                                          : 'No customer selected',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))),
                              if (_loading)
                                const Column(children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                          child: CircularProgressIndicator())),
                                  SizedBox(height: 6)
                                ])
                              else
                                GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context)
                                          .unfocus(); // Unfocus any focused text fields
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Date of Request
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: Text(
                                                'Date of Request: ${DateFormat.yMMMd().format(dateOfRequest)}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: Text(
                                                'Date Assigned: ${DateFormat.yMMMd().format(dateOfRequest)}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: Text(
                                                'Home Address: ${selectedCustomer?.address}, ${selectedCustomer?.city}, ${selectedCustomer?.state} ${selectedCustomer?.zip}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            // Project Dropdown
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: DropdownButtonFormField<
                                                      String>(
                                                  value: selectedProject,
                                                  isExpanded: true,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedProject = value;
                                                    });
                                                  },
                                                  items: _projects,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Select Project',
                                                    labelStyle:
                                                        TextStyle(fontSize: 14),
                                                    border:
                                                        OutlineInputBorder(),
                                                  )),
                                            ),
                                            const SizedBox(height: 5),
                                            // Caller Dropdown + Info
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: DropdownButtonFormField<
                                                      int>(
                                                  value: ownerWhoCalled,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      newCellPhone = null;
                                                      if (value != null) {
                                                        ownerWhoCalled = value;
                                                      }
                                                    });
                                                  },
                                                  items: [
                                                    DropdownMenuItem(
                                                      value: 1,
                                                      child: Text(
                                                        '${selectedCustomer?.fname1} ${selectedCustomer?.lname1} | ${cellPhoneRepr(selectedCustomer?.cellPhone1 ?? "")}',
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 2,
                                                      child: Text(
                                                        '${selectedCustomer?.fname2} ${selectedCustomer?.lname2} | ${cellPhoneRepr(selectedCustomer?.cellPhone2 ?? "")}',
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    )
                                                  ],
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Select Owner who Made Call (Is Caller)',
                                                    labelStyle:
                                                        TextStyle(fontSize: 14),
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black)),
                                            ),
                                            if (!hasNumber()) ...[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: TextFormField(
                                                  maxLines: 1,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      newCellPhone = value;
                                                    });
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: const InputDecoration(
                                                      labelText:
                                                          'Provide a cell number',
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelStyle: TextStyle(
                                                          fontSize: 14)),
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  onTapOutside: (event) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                ),
                                              )
                                            ],
                                            const SizedBox(height: 5),
                                            // Service Provider Dropdown
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: DropdownButtonFormField<
                                                      String>(
                                                  value:
                                                      selectedServiceProvider,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedServiceProvider =
                                                          value;
                                                    });
                                                  },
                                                  items: _serviceProviders,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Select Service Provider',
                                                    labelStyle:
                                                        TextStyle(fontSize: 14),
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black)),
                                            ),
                                            // Problem Description
                                            const SizedBox(height: 5),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: TextFormField(
                                                maxLines: 5,
                                                onChanged: (value) {
                                                  setState(() {
                                                    problemDescription = value;
                                                  });
                                                },
                                                decoration: const InputDecoration(
                                                    labelText:
                                                        'Problem Description',
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelStyle: TextStyle(
                                                        fontSize: 14)),
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                onTapOutside: (event) {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            SizedBox(
                                              width: double
                                                  .infinity, // Spans the width of the screen
                                              child: ElevatedButton(
                                                onPressed: hasNumber() ||
                                                        newCellPhone != null
                                                    ? createServiceOrder
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors
                                                      .blue, // Solid blue background
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical:
                                                          16), // Increase button height
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10), // No rounded corners
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Submit',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors
                                                        .white, // White text color
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20),
                                                child: Text(_errorMessage,
                                                    style: const TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 14))),
                                          ],
                                        ),
                                      ],
                                    ))
                            ]))
                ])));
  }
}
