import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/customers/appointment_view.dart';
import 'package:normandy_app/src/customers/appointments_type.dart';
import 'package:normandy_app/src/customers/customer_type.dart';
import 'package:normandy_app/src/customers/jobs_type.dart';
import 'package:normandy_app/src/customers/service_order_type.dart';
import 'package:normandy_app/src/so_forms/create_so.dart';
import 'package:normandy_app/src/so_forms/user_class.dart';
import 'package:normandy_app/src/customers/note_type.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailPage extends StatefulWidget {
  final String customerId;

  const CustomerDetailPage({Key? key, required this.customerId})
      : super(key: key);

  @override
  _CustomerDetailPageState createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  Customer? customer;
  User? customerContact;
  List<Note> notes = [];
  List<Appointment> appointments = [];
  List<Job> jobs = [];
  List<ServiceOrder> serviceOrders = [];
  // String userId = '';

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
    // fetchUserId();
  }

  void fetchCustomerDetails() async {
    var response =
        await APIHelper.get('customers/${widget.customerId}', context, mounted);
    if (response != null && response.statusCode == 200 && mounted) {
      var newCustomer =
          Customer.fromJson(json.decode(response.body)['customer']);
      setState(() {
        customer = newCustomer;
      });

      if (newCustomer.customerContactID != '') {
        var response2 = await APIHelper.get(
            'users/${newCustomer.customerContactID}', context, mounted);
        if (response2 != null && response2.statusCode == 200) {
          var newCustomerContact =
              User.fromJson(json.decode(response2.body)['user']);
          setState(() {
            customerContact = newCustomerContact;
          });
        }
      }

      var notesResponse = await APIHelper.get(
          'notes?customerId=${widget.customerId}&noteFor=customer',
          context,
          mounted);
      if (notesResponse != null && notesResponse.statusCode == 200) {
        var newNotes = (json.decode(notesResponse.body)['notes'] as List)
            .map((note) => Note.fromJson(note))
            .toList();
        setState(() {
          notes = newNotes;
        });
      }

      var appointmentsResponse = await APIHelper.get(
          'appointments?customerId=${widget.customerId}',
          context,
          mounted);
      if (appointmentsResponse != null && appointmentsResponse.statusCode == 200) {
        var newAppointments = (json.decode(appointmentsResponse.body)['appointments'] as List)
            .map((appointment) => Appointment.fromJson(appointment))
            .toList();
        setState(() {
          appointments = newAppointments;
        });
      }
 
     var jobsResponse = await APIHelper.get(
          'projects?customerId=${widget.customerId}&includeJobStateName=true',
          context,
          mounted);
      if (jobsResponse != null && jobsResponse.statusCode == 200) {
        var newJobs = (json.decode(jobsResponse.body)['projects'] as List)
            .map((job) => Job.fromJson(job))
            .toList();
        setState(() {
          jobs = newJobs;
        });
      }

      var serviceOrdersResponse = await APIHelper.get(
          'service-orders?customerId=${widget.customerId}',
          context,
          mounted);
      if (serviceOrdersResponse != null && serviceOrdersResponse.statusCode == 200) {
        var newServiceOrders = (json.decode(serviceOrdersResponse.body)['serviceOrders'] as List)
            .map((serviceOrder) => ServiceOrder.fromJson(serviceOrder))
            .toList();
        setState(() {
          serviceOrders = newServiceOrders;
          print(serviceOrders);
        });
      }

      if (kDebugMode) print(customerContact?.email ?? 'No email found');
    }
  }

  // void fetchUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if(prefs.getString('email') == null) {
  //     return;
  //   }
  //   var response = await APIHelper.get('users/:email/?${prefs.getString('email')}', context, mounted);
  //   if (response != null && response.statusCode == 200) {
  //     print(response.body);
  //     var user = User.fromJson(json.decode(response.body)['user']);
  //     setState(() {
  //       userId = user.userId ?? '';
  //     });
  //   }
  // }

  void openMailApp(List<String> emails) {
    if (emails.isEmpty || emails.every((email) => email.isEmpty)) return;
    final emailString = emails.where((email) => email.isNotEmpty).join(',');
    launchUrl(Uri.parse('mailto:$emailString'));
  }

  void openPhoneApp(String? phone1, String? phone2, String? phone3) {
    final phone = phone1?.isNotEmpty == true
        ? phone1
        : phone2?.isNotEmpty == true
            ? phone2
            : phone3?.isNotEmpty == true
                ? phone3
                : null;

    if (phone != null) {
      launchUrl(Uri.parse('tel:$phone'));
    }
  }

  void openMessageApp(String? phone1, String? phone2, String? phone3) {
    final phone = phone1?.isNotEmpty == true
        ? phone1
        : phone2?.isNotEmpty == true
            ? phone2
            : phone3?.isNotEmpty == true
                ? phone3
                : null;

    if (phone != null) {
      launchUrl(Uri.parse('sms:$phone'));
    }
  }

  void launchMapUrl(String address) async {
    final Uri appleURL = Uri.parse(
    'https://maps.apple.com/?q=${Uri.encodeComponent(address)}',
    );

    if (await canLaunchUrl(appleURL)) {
      await launchUrl(appleURL);
    } else {
      final Uri googleURL = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
      );
      if (await canLaunchUrl(googleURL)) {
        await launchUrl(googleURL);
      } else {
        throw 'Could not launch $address';
      }
    }
  }

  Widget customerButtons(
      VoidCallback onTap, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: 28,
          color: color,
        ),
      ),
    );
  }

  Widget sendMultipleEmails(String? email1, String? email2) {
    if (email1?.isNotEmpty == true && email2?.isNotEmpty == true) {
      return GestureDetector(
          onTap: () => openMailApp([email1 ?? "", email2 ?? ""]),
          child: SizedBox(
            width: 45,
            child: Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Icon(Icons.email, color: Colors.blue, size: 28),
                    Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.group,
                            color: Colors.blue,
                            size: 10,
                          ),
                        )),
                  ],
                )),
          ));
    }
    return SizedBox(
      width: 45,
      child: Align(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Icon(Icons.email, color: Colors.grey, size: 28),
              Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.group,
                      color: Colors.grey,
                      size: 10,
                    ),
                  )),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${customer?.lname1} - ${customer?.city}"),
        centerTitle: true,
      ),
      body: (customer == null) 
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                customer?.fname1 ?? '',
                                style: TextStyle(fontSize: 16),
                              ),
                              Row(
                                children: [
                                  customerButtons(
                                      () => openPhoneApp(
                                          customer?.cellPhone1,
                                          customer?.homePhone1,
                                          customer?.workPhone1),
                                      Icons.phone,
                                      (customer?.cellPhone1.isNotEmpty ==
                                                  true ||
                                              customer?.homePhone1.isNotEmpty ==
                                                  true ||
                                              customer?.workPhone1.isNotEmpty ==
                                                  true)
                                          ? Colors.blue
                                          : Colors.grey),
                                  customerButtons(
                                      () => openMessageApp(
                                          customer?.cellPhone1,
                                          customer?.homePhone1,
                                          customer?.workPhone1),
                                      Icons.message,
                                      (customer?.cellPhone1.isNotEmpty ==
                                                  true ||
                                              customer?.homePhone1.isNotEmpty ==
                                                  true ||
                                              customer?.workPhone1.isNotEmpty ==
                                                  true)
                                          ? Colors.blue
                                          : Colors.grey),
                                  customerButtons(
                                      () =>
                                          openMailApp([customer?.email ?? '']),
                                      Icons.email,
                                      (customer?.email.isNotEmpty == true)
                                          ? Colors.blue
                                          : Colors.grey),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                customer?.fname2 ?? '',
                                style: TextStyle(fontSize: 16),
                              ),
                              Row(
                                children: [
                                  customerButtons(
                                      () => openPhoneApp(
                                          customer?.cellPhone2,
                                          customer?.homePhone2,
                                          customer?.workPhone2),
                                      Icons.phone,
                                      (customer?.cellPhone2.isNotEmpty ==
                                                  true ||
                                              customer?.homePhone2.isNotEmpty ==
                                                  true ||
                                              customer?.workPhone2.isNotEmpty ==
                                                  true)
                                          ? Colors.blue
                                          : Colors.grey),
                                  customerButtons(
                                      () => openMessageApp(
                                          customer?.cellPhone2,
                                          customer?.homePhone2,
                                          customer?.workPhone2),
                                      Icons.message,
                                      (customer?.cellPhone2.isNotEmpty ==
                                                  true ||
                                              customer?.homePhone2.isNotEmpty ==
                                                  true ||
                                              customer?.workPhone2.isNotEmpty ==
                                                  true)
                                          ? Colors.blue
                                          : Colors.grey),
                                  customerButtons(
                                      () =>
                                          openMailApp([customer?.email2 ?? '']),
                                      Icons.email,
                                      (customer?.email2.isNotEmpty == true)
                                          ? Colors.blue
                                          : Colors.grey),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    // customer?.email != "" && customer?.email2 != "" && customer?.email != null && customer?.email2 != null
                    //   ? SizedBox(
                    //       width: 45,
                    //       child: Align(
                    //         alignment: Alignment.center,
                    //         child: GestureDetector(
                    //             onTap: () => openMailApp([
                    //                   "${customer?.email},${customer?.email2}"
                    //                 ]),
                    //             child: Icon(
                    //               Icons.email,
                    //               size: 28,
                    //               color: Colors.blue,
                    //             )),
                    //       ),
                    //     )
                    //   : SizedBox.shrink(),

                    sendMultipleEmails(customer?.email, customer?.email2)
                  ]),
                  SizedBox(height: 5),
                  if (customerContact != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          customerContact?.displayName ??
                              customer?.lastSoldJobDesignerName ??
                              'N/A',
                          style: TextStyle(fontSize: 16),
                        ), 
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => launchUrl(Uri.parse(
                                  'msteams:/l/call/0/0?users=${customerContact!.email}')),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.call,
                                  size: 28,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => launchUrl(Uri.parse(
                                  'msteams:/l/chat/0/0?users=${customerContact!.email}')),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.message,
                                  size: 28,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  openMailApp([customerContact!.email]),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.email,
                                  size: 28,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(width: 45)
                          ],
                        )
                      ],
                    ),
                  ],
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => launchMapUrl(
                        "${customer?.address ?? 'N/A'}, ${customer?.city ?? 'N/A'}, ${customer?.state ?? 'N/A'} ${customer?.zip ?? 'N/A'}"),
                    child: Text(
                      "${customer?.address ?? 'N/A'}\n${customer?.city ?? 'N/A'}, ${customer?.state ?? 'N/A'} ${customer?.zip ?? 'N/A'}",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                  Text(
                    "Tax ID: ${customer?.taxId ?? 'N/A'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Sharepoint Folder Name: ${customer?.spFolderName ?? 'N/A'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  if (notes.isNotEmpty) ...[
                    Text(
                      "Notes",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    ...notes.map((note) => Text(
                          "${note.author.displayName} (${note.author.occupation}) | ${DateFormat.yMd().add_jm().format(DateTime.parse(note.postTime))}\n${note.content}",
                          style: TextStyle(fontSize: 16),
                        )),
                  ],
                  SizedBox(height: 20),
                  Text(
                    "Appointments",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5), 
                  ...appointments.map((appointment) => GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentView(
                              appointment: appointment,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            "${appointment.lname} - ${appointment.city} - Started ${DateFormat.yMd().format(appointment.dateOfRequest ?? DateTime.now())}",
                            style: TextStyle(fontSize: 16),
                          ),
                          trailing: Icon(Icons.chevron_right),
                        )
                    )
                  ),
                  Text(appointments.isEmpty == true ? "No appointments" : ""),
                  SizedBox(height: 5),
                  Text(
                    "Jobs",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5), 
                  ...jobs.map((job) => GestureDetector(
                        // onTap: () => Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => AppointmentView(
                        //       appointment: job,
                        //     ),
                        //   ),
                        // ),
                        child: ListTile(
                          title: Text(
                            "${job.lname} - ${job.jobCity} - Completed ${DateFormat.yMd().format(job.jobCompletionDate ?? DateTime.now())}",
                            style: TextStyle(fontSize: 16),
                          ),
                          trailing: Icon(Icons.chevron_right),
                        )
                    )
                  ),
                  Text(jobs.isEmpty == true ? "No jobs" : ""),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        "Service Orders",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Spacer(), 
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateSOForm(selectedCustomer: customer)
                          ),
                        ),
                        child: Icon(Icons.add),
                      )
                    ],
                  ),
                  SizedBox(height: 5),  
                  ...serviceOrders.map((serviceOrder) => GestureDetector(
                        // onTap: () => Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => AppointmentView(
                        //       appointment: job,
                        //     ),
                        //   ),
                        // ),
                        child: ListTile(
                          title: Text(
                            "${serviceOrder.name} - ${serviceOrder.city} - Request Date ${DateFormat.yMd().format(serviceOrder.dateOfRequest ?? DateTime.now())}",
                            style: TextStyle(fontSize: 16),
                          ),
                          trailing: Icon(Icons.chevron_right),
                        )
                    )
                  ),
                  Text(serviceOrders.isEmpty == true ? "No service orders" : ""),
                  // SizedBox(height: 20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     ElevatedButton.icon(
                  //       onPressed: () {
                  //         // Add to one drive
                  //         APIHelper.post('/customers/:cid/shortcut?${customer!.customerId}', {"userId": userId}, context, mounted);
                  //       },
                  //       icon: Icon(Icons.add),
                  //       label: Text("Add Shortcut to OneDrive"),
                  //     ),
                  //     ElevatedButton.icon(
                  //       onPressed: () {
                  //         // Logic to open OneDrive
                  //         launchUrl(Uri.parse('https://onedrive.live.com/'));
                  //       },
                  //       icon: Icon(Icons.cloud),
                  //       label: Text("Open OneDrive"),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
    );
  }
}
