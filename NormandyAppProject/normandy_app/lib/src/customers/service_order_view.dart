import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:normandy_app/src/customers/jobs_type.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/customers/service_order_type.dart';

class ServiceOrderView extends StatefulWidget {
  final ServiceOrder serviceOrder;
  final String nameAndCity;

  const ServiceOrderView(
      {Key? key, required this.serviceOrder, required this.nameAndCity})
      : super(key: key);

  @override
  _ServiceOrderViewState createState() => _ServiceOrderViewState();
}

class _ServiceOrderViewState extends State<ServiceOrderView> {
  Map appointmentDetails = {};

  @override
  void initState() {
    super.initState();
    // fetchAppointmentDetails();
  }
  // String appointmentId = widget.appointment.id ?? "";

  // void fetchJobDetails() async {
  //   var appointmentsResponse = await APIHelper.get(
  //         'appointments//format',
  //         context,
  //         mounted);
  //     if (appointmentsResponse != null && appointmentsResponse.statusCode == 200) {
  //       var newAppointment = (jsonDecode(appointmentsResponse.body)['appointment']);
  //       setState(() {
  //         appointmentDetails = newAppointment;
  //       });
  //     }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Order Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Align(alignment: Alignment.center, child: Text(widget.nameAndCity)),
            SizedBox(height: 15),
            _buildDetailRow(
                'Date of Request',
                widget.serviceOrder.dateOfRequest != null
                    ? DateFormat.yMd()
                        .format(widget.serviceOrder.dateOfRequest as DateTime)
                    : "N/A"),
            _buildDetailRow('Took Call', widget.serviceOrder.tookCallName),
            _buildDetailRow('Problem Description', ""),
            _buildDetailRow('', widget.serviceOrder.description),
            _buildDetailRow('Solution', widget.serviceOrder.solution),
            _buildDetailRow(
                'Date Completed',
                widget.serviceOrder.dateJobCompleted != null
                    ? DateFormat.yMd().format(
                        widget.serviceOrder.dateJobCompleted as DateTime)
                    : "N/A"),
            _buildDetailRow('Service Providers', ""),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.serviceOrder.serviceHandler!.map<Widget>((item) {
                return ListTile(
                  title: Text(item.customServiceHandler ?? 'No service handlers'),
                  subtitle: Text(
                    item.dateAssigned != null
                        ? DateFormat.yMd().format(item.dateAssigned as DateTime)
                        : "N/A",
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}
