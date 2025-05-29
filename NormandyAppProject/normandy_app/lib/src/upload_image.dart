import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/api/alert_helper.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/onedrive_shortcuts/customer_class.dart';
import 'package:normandy_app/src/onedrive_shortcuts/custom_search_delegate.dart';
import 'package:normandy_app/src/client_choose_image.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key});

  @override
  UploadImageState createState() => UploadImageState();
}

class UploadImageState extends State<UploadImage> {
  String? jwt;
  Customer? selectedCustomer;
  String? selectedProject;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  void handleSelectCustomer(Customer customer) {
    print(customer.folderName);
    print(customer.fname1);
    print(customer.lname1);
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
        appBar: AppBar(title: Text('Upload Images'), actions: [
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
                              if (selectedCustomer != null)
                                GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context)
                                        .unfocus(); // Unfocus any focused text fields
                                  },
                                  child: SizedBox(
                                    // TODO fill rest instead of hard coding
                                    height: 600,
                                    child: ClientChooseImagePage(
                                        name: selectedCustomer!.folderName),
                                  ),
                                )
                            ]))
                ])));
    // return Scaffold(
    //     appBar: AppBar(title: Text('Upload Images'), actions: [
    //       IconButton(
    //           onPressed: () async {
    //             await showSearch(
    //                 context: context,
    //                 delegate: CustomSearchDelegate(
    //                     context: context,
    //                     mounted: mounted,
    //                     onSelectCustomer: handleSelectCustomer));
    //           },
    //           icon: const Icon(Icons.search))
    //     ]),
    //     body: SingleChildScrollView(
    //         // Wrap the body in SingleChildScrollView
    //         padding: const EdgeInsets.all(16),
    //         child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[
    //               if (selectedCustomer == null)
    //                 ListTile(title: Text('Start typing to search'))
    //               else
    //                 Container(
    //                     margin: const EdgeInsets.only(top: 10),
    //                     padding: const EdgeInsets.only(
    //                         left: 4, right: 4, top: 4, bottom: 20),
    //                     width: MediaQuery.of(context).size.width,
    //                     child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Padding(
    //                               padding: const EdgeInsets.only(bottom: 10),
    //                               child: Text(
    //                                   selectedCustomer != null
    //                                       ? selectedCustomer!.folderName
    //                                       : 'No customer selected',
    //                                   style: const TextStyle(
    //                                       fontWeight: FontWeight.bold,
    //                                       fontSize: 18))),
    //                           if (_loading)
    //                             const Column(children: [
    //                               Padding(
    //                                   padding:
    //                                       EdgeInsets.symmetric(vertical: 20),
    //                                   child: Center(
    //                                       child: CircularProgressIndicator())),
    //                               SizedBox(height: 6)
    //                             ])
    //                           else if (selectedCustomer != null)
    //                             GestureDetector(
    //                               onTap: () {
    //                                 FocusScope.of(context)
    //                                     .unfocus(); // Unfocus any focused text fields
    //                               },
    //                               child: SizedBox(
    //                                 height: 400,
    //                                 child: ClientChooseImagePage(
    //                                     name: selectedCustomer!.folderName),
    //                               ),
    //                             )
    //                         ]))
    //             ])));
  }
}
