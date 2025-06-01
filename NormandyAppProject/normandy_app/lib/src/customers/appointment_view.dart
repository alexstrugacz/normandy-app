import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointments_type.dart';

class AppointmentView extends StatelessWidget {
  final Appointment appointment;

  const AppointmentView({Key? key, required this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Date of Request', appointment.dateOfRequest != null ? DateFormat.yMd().format(appointment.dateOfRequest ?? DateTime.now()) : "N/A"),
            _buildDetailRow('Date Run', appointment.dateRun != null ? DateFormat.yMd().format(appointment.dateRun ?? DateTime.now()) : "N/A"),
            _buildDetailRow('Designer', appointment.designerName),
            _buildDetailRow("Designer 2", appointment.designerName2), // Handle getting name from ID
            _buildDetailRow("Designer in Training", appointment.designerInTrainingId),
            _buildDetailRow("Type of Work", appointment.projectDescription),
            _buildDetailRow("Year Built", appointment.yearBuilt?.toString()),
            _buildDetailRow("Confirmation Sent", appointment.confirmationLetterSent?.toString()),
            _buildDetailRow("Taken By", appointment.takenById), // Handle getting name from ID
            _buildDetailRow("Time Set", appointment.timeSet),
            _buildDetailRow("Source 1", appointment.leadSourceId), // Handle getting lead source name from ID
            _buildDetailRow("Source 2", appointment.leadSource2Id), // Handle getting lead source 2 name from ID
            _buildDetailRow("Refered by (Known)", appointment.referredById), // Handle getting referred by name from ID
            _buildDetailRow("Referred by (Unknown)", appointment.referredBy),
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