import 'dart:io';

import 'package:flutter/material.dart';

class ExpenseCodePage extends StatefulWidget {
  final File image;
  final String imagePath;
  const ExpenseCodePage({
    super.key,
    required this.image,
    required this.imagePath,
  });

  @override
  ExpenseCodePageState createState() => ExpenseCodePageState();
}

class ExpenseCodePageState extends State<ExpenseCodePage> {
  String jobNonJobValue = 'Non-Job';
  String? clientValue;
  String? accountingCodeValue;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final List<String> clients = [
    'Client 1',
    'Client 2',
    'Client 3'
  ]; // Pull clients from normandy backend
  final List<Map<String, String>> accountingCodes = [
    {'Operational Expenses': '7200'},
    {'Meetings': '7880'},
    {'Miscellaneous/Office Supplies': '7800'},
    {'Job Expenses (90-980)': '5150'},
    {'Telephone Charges': '7810'},
    {'Travel': '7300'},
    {'Customer/Client Gifts': '7150'},
    {'Employee Benefits': '6530'},
    {'Education/Training': '6540'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
          children: [
            Image(
              image: FileImage(widget.image),
            ),
            DropdownButtonFormField<String>(
              value: jobNonJobValue,
              onChanged: (value) {
                setState(() {
                  jobNonJobValue = value!;
                  if (value == 'Job') {
                    accountingCodeValue = '5150'; // Automatically code as 5150
                  }
                });
              },
              items: ['Job', 'Non-Job'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Job/Non-Job',
              ),
            ),
            if (jobNonJobValue == 'Job')
              DropdownButtonFormField<String>(
                value: clientValue,
                onChanged: (value) {
                  setState(() {
                    clientValue = value!;
                  });
                },
                items: clients.map((String client) {
                  return DropdownMenuItem<String>(
                    value: client,
                    child: Text(client),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Client',
                ),
              ),
            DropdownButtonFormField<String>(
              value: accountingCodeValue,
              onChanged: (value) {
                setState(() {
                  accountingCodeValue = value!;
                });
              },
              items: accountingCodes.map((Map<String, String> code) {
                return DropdownMenuItem<String>(
                  value: code.values.first,
                  child: Text('${code.keys.first} (${code.values.first})'),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Accounting Code',
              ),
            ),
            TextFormField(
              controller: descriptionController,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Send data to normandy backend
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
        )
      ),
    );
  }
}
