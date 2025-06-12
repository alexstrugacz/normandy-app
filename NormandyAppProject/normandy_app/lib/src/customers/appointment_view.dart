import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointments_type.dart';
import 'package:normandy_app/src/api/api_helper.dart';

class AppointmentView extends StatefulWidget {
  final Appointment appointment;
  final String nameAndCity;

  const AppointmentView({Key? key, required this.appointment, required this.nameAndCity}) 
      : super(key: key);
  
  @override 
  _AppointmentViewState createState() => _AppointmentViewState();
}

class _AppointmentViewState extends State<AppointmentView> {
  Map appointmentDetails = {};

  @override
  void initState() {
    super.initState();
    fetchAppointmentDetails();
  }
  // String appointmentId = widget.appointment.id ?? "";

  void fetchAppointmentDetails() async {
    var appointmentsResponse = await APIHelper.get(
          'appointments/${widget.appointment.id}/format',
          context,
          mounted);
      if (appointmentsResponse != null && appointmentsResponse.statusCode == 200) {
        var newAppointment = (jsonDecode(appointmentsResponse.body)['appointment']);
        setState(() {
          appointmentDetails = newAppointment;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Align(alignment: Alignment.center, child: Text(widget.nameAndCity)),
            SizedBox(height: 15),
            _buildDetailRow('Date of Request', widget.appointment.dateOfRequest != null ? DateFormat.yMd().format(widget.appointment.dateOfRequest as DateTime) : "N/A"),
            _buildDetailRow('Date Run', widget.appointment.dateRun != null ? DateFormat.yMd().format(widget.appointment.dateRun as DateTime) : "N/A"),
            _buildDetailRow('Designer', appointmentDetails['Designer'] ?? "N/A"),
            _buildDetailRow("Designer 2", appointmentDetails['Designer2'] ?? "N/A"),
            _buildDetailRow("Designer in Training", appointmentDetails['DesignerInTraining'] ?? "N/A"),
            _buildDetailRow("Type of Work", widget.appointment.projectDescription ?? "N/A"),
            _buildDetailRow("Year Built", appointmentDetails['YearBuilt'] != null ? DateFormat.yMd().format(appointmentDetails['YearBuilt'] as DateTime) : "N/A"),
            _buildDetailRow("Confirmation Sent", widget.appointment.confirmationLetterSent == true ? "Yes" : "No"),
            _buildDetailRow("Taken By", appointmentDetails['TakenBy'] ?? "N/A"),
            _buildDetailRow("Time Set", widget.appointment.timeSet ?? "N/A"),
            _buildDetailRow("Source 1", appointmentDetails['LeadSource'] ?? "N/A"),
            _buildDetailRow("Source 2", appointmentDetails['LeadSource2'] ?? "N/A"),
            _buildDetailRow("Referred by (Known)", appointmentDetails['ReferredByKnown'] ?? "N/A"),
            _buildDetailRow("Referred by (Unknown)", appointmentDetails['ReferredByUnknown'] ?? "N/A"),
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