import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:normandy_app/src/customers/jobs_type.dart'; 
import 'package:normandy_app/src/api/api_helper.dart';

class JobView extends StatefulWidget {
  final Job job;
  final String nameAndCity;

  const JobView({Key? key, required this.job, required this.nameAndCity}) 
      : super(key: key);
  
  @override 
  _JobViewState createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
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
        title: Text('Job Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Align(alignment: Alignment.center, child: Text(widget.nameAndCity)),
            SizedBox(height: 15),
            // _buildDetailRow('Appointment', ""),
            _buildDetailRow('Job Number', widget.job.jobId),
            _buildDetailRow('Job Description', widget.job.jobDescription),
            // _buildDetailRow('Job Type', ""),
            // _buildDetailRow('Designer 1', ""),
            // _buildDetailRow('Share #1', ""), 
            // _buildDetailRow('Designer 2', ""), 
            // _buildDetailRow('Share #2', ""),
            // _buildDetailRow('Designer in Training', ""),
            // _buildDetailRow('Superintendent', ""),
            _buildDetailRow('Date Sold', widget.job.dateSold != null ? DateFormat.yMd().format(widget.job.dateSold as DateTime) : "N/A"),
            // _buildDetailRow('Date Measured', ""),
            // _buildDetailRow('Date Ready', ""),
            // _buildDetailRow('In House Schedule Date', ""),
            // _buildDetailRow('Client Schedule', ""),
            _buildDetailRow('Job Completed Date', widget.job.jobCompletionDate != null ? DateFormat.yMd().format(widget.job.jobCompletionDate as DateTime) : "N/A"),
            _buildDetailRow('Substantial Completed Date', widget.job.substantialCompleted != null ? DateFormat.yMd().format(widget.job.substantialCompleted as DateTime) : "N/A"),
            _buildDetailRow('Final Inspection', widget.job.finalInspection != null ? DateFormat.yMd().format(widget.job.finalInspection as DateTime) : "N/A"),
            // _buildDetailRow('Bond Balance', ""),
            // _buildDetailRow('Year Built', ""),
            // _buildDetailRow('Lead Check', ""),
            // _buildDetailRow('Letter Sent', ""),
            _buildDetailRow('Letter Sent Date', widget.job.realityLetterSent != null ? DateFormat.yMd().format(widget.job.realityLetterSent as DateTime) : "N/A"),
            // _buildDetailRow('Job Address', ""),
            _buildDetailRow('Job City', widget.job.jobCity),
            _buildDetailRow('Contingency on Sale', widget.job.contingency),
            _buildDetailRow('Limbo', widget.job.limbo),
            // _buildDetailRow('Job Status', ""),
            // _buildDetailRow('Job Source 1', ""),
            // _buildDetailRow('Job Source 2', ""),
            // _buildDetailRow('First Contact', ""),
            // _buildDetailRow('Design Price', ""),
            // _buildDetailRow('Design Cost', ""),
            // _buildDetailRow('Design MU', ""),
            // _buildDetailRow('Estimate Price', ""),
            // _buildDetailRow('Estimate Cost', ""),
            // _buildDetailRow('Estimate MU', ""),
            _buildDetailRow('Final Price', "\$${widget.job.finalPrice}"),
            // _buildDetailRow('Kitchen Cost', ""), 
            _buildDetailRow('Final Cost', "\$${widget.job.jobCost}"), 
            // _buildDetailRow('Final MU', ""),
            // _buildDetailRow('Permits?', ""),
            // _buildDetailRow('Permit', ""),
            // _buildDetailRow('Permit Number', ""), 
            // _buildDetailRow('Foundation', ""), 
            // _buildDetailRow('Cabinet Vendor', ""),
            // _buildDetailRow('Latitude', ""), 
            // _buildDetailRow('Longitude', ""), 
            // _buildDetailRow('Cabinet Vendor', ""),
            _buildDetailRow('Job ID', widget.job.jobNumber)
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