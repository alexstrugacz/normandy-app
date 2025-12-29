

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:normandy_app/src/customers/customer_type.dart';
import 'package:normandy_app/src/onedrive_shortcuts/custom_search_delegate.dart';
import 'package:normandy_app/src/client_choose_image.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key});

  @override
  UploadImageState createState() => UploadImageState();
}

class UploadImageState extends State<UploadImage> {
  String? jwt;
  Customer? selectedCustomer;
  String? selectedProject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSearch(
        context: context,
        delegate: CustomSearchDelegate(
          context: context,
          mounted: mounted,
          onSelectCustomer: handleSelectCustomer,
        ),
      );
    });
  }

  // String _errorMessage = '';

  void handleSelectCustomer(Customer customer) async {
    if (kDebugMode) {
      print(customer.folderName);
      print(customer.fname1);
      print(customer.lname1);
    }
    /*
    String folderName = customer.folderName;
    http.Response? response =
        await APIHelper.get('customers/${customer.id}', context, mounted);

    if ((response == null) || response.statusCode != 200) {
      return;
    }
    */

    setState(() {
      selectedCustomer = customer;
    });
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Upload Images'), actions: [
          IconButton(
              onPressed: () async {
                await showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(
                        context: context,
                        mounted: mounted,
                        onSelectCustomer: handleSelectCustomer));
              },
              icon: const Icon(Icons.search))
        ]),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (selectedCustomer == null)
                    const ListTile(title: Text('Start typing to search'))
                  else
                    Expanded(
                        child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.only(
                                left: 4, right: 4, top: 4, bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(selectedCustomer!.folderName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))),
                                  Expanded(
                                    child: ClientChooseImagePage(
                                        name: selectedCustomer!.folderName,
                                        customerId: selectedCustomer!.id),
                                  ),
                                ])))
                ])));
  }
}
