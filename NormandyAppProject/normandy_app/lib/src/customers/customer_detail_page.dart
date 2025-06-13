import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/customers/appointment_view.dart';
import 'package:normandy_app/src/customers/appointments_type.dart';
import 'package:normandy_app/src/customers/buttons/add_shortcut.dart';
import 'package:normandy_app/src/customers/buttons/call_button.dart';
import 'package:normandy_app/src/customers/buttons/link_button.dart';
import 'package:normandy_app/src/customers/buttons/send_email.dart';
import 'package:normandy_app/src/customers/buttons/send_message.dart';
import 'package:normandy_app/src/customers/buttons/send_multiple_emails.dart';
import 'package:normandy_app/src/customers/customer_type.dart';
import 'package:normandy_app/src/customers/job_view.dart';
import 'package:normandy_app/src/customers/jobs_type.dart';
import 'package:normandy_app/src/customers/service_order_type.dart';
import 'package:normandy_app/src/customers/service_order_view.dart';
import 'package:normandy_app/src/so_forms/create_so.dart';
import 'package:normandy_app/src/customers/customer_utils.dart';
import 'package:normandy_app/src/so_forms/edit_so.dart';
import 'package:normandy_app/src/so_forms/user_class.dart';
import 'package:normandy_app/src/customers/note_type.dart';

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
  bool _loading = false;
  List<Job> jobs = [];
  List<ServiceOrder> serviceOrders = [];
  // String userId = '';

  @override
  void initState() {
    super.initState();
    _fetchCustomerDetails();
    // fetchUserId();
  }

  void _fetchCustomerDetails() async {
    _loading = true;

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
        });
      }

      if (kDebugMode) print(customerContact?.email ?? 'No email found');
    }
    _loading = false;
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
                                  CallButton(phoneNumbers: [
                                      customer?.cellPhone1 ?? '',
                                      customer?.homePhone1 ?? '',
                                      customer?.workPhone1 ?? ''
                                  ]),
                                  SendMessageButton(phoneNumbers: [
                                      customer?.cellPhone1 ?? '',
                                      customer?.homePhone1 ?? '',
                                      customer?.workPhone1 ?? ''
                                  ]),
                                  EmailButton(email: customer?.email ?? ''),
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
                                  CallButton(phoneNumbers: [
                                      customer?.cellPhone2 ?? '',
                                      customer?.homePhone2 ?? '',
                                      customer?.workPhone2 ?? ''
                                  ], email: customer?.email2),
                                  SendMessageButton(phoneNumbers: [
                                      customer?.cellPhone2 ?? '',
                                      customer?.homePhone2 ?? '',
                                      customer?.workPhone2 ?? ''
                                  ], email: customer?.email2),
                                  EmailButton(email: customer?.email2 ?? ''),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SendMultipleEmailsButton(
                      email1: customer?.email ?? '', 
                      email2: customer?.email2 ?? ''
                    ),
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
                            CallButton(
                              phoneNumbers: [], 
                              email: customerContact!.email),
                            SendMessageButton(
                              phoneNumbers: [], 
                              email: customerContact!.email
                            ),
                            EmailButton(email: customerContact!.email),
                            SizedBox(width: 45)
                          ],
                        )
                      ],
                    ),
                  ],
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => CustomerUtils.launchMapUrl(customer),
                    child: Text(
                      CustomerUtils.generateCustomerAddress(customer),
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                  Text(
                    "Tax ID: ${customer?.taxId == "" ? 'N/A' : customer!.taxId}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Sharepoint Folder Name: ${customer?.spFolderName == "" ? 'N/A' : customer!.spFolderName}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  AddShortcutToOneDrive(text: "Add Shortcut to OneDrive", customer: customer, mounted: mounted, icon: Icons.cloud),
                  SizedBox(height: 5),
                  LinkButton(text: "Open Client Active Folders", url: customer!.spUrl, icon: Icons.folder, openInApp: true, overrideColor: Colors.grey),
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
                              nameAndCity: "${customer?.lname1} - ${customer?.city}"
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            "${appointment.lname} - ${appointment.city}\nStarted ${DateFormat.yMd().format(appointment.dateOfRequest ?? DateTime.now())}",
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobView(
                              job: job,
                              nameAndCity: "${customer?.lname1} - ${customer?.city}"
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            '${job.lname} - ${job.jobCity}\nCompleted ${DateFormat.yMd().format(job.jobCompletionDate ?? DateTime.now())}',
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
                            builder: (context) => CreateSOForm(customer: customer)
                          ),
                        ),
                        child: Icon(Icons.add),
                      )
                    ],
                  ),
                  SizedBox(height: 5),  
                  ...serviceOrders.map((serviceOrder) => GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditSOForm(
                              customer: customer,
                              serviceOrderId: serviceOrder.id,
                              projectId: serviceOrder.projectId,
                              nameAndCity: "${customer?.lname1} - ${customer?.city}"
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            "${serviceOrder.name ?? customer?.lname1} - ${serviceOrder.city}\nRequest Date ${DateFormat.yMd().format(serviceOrder.dateOfRequest ?? DateTime.now())}",
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
