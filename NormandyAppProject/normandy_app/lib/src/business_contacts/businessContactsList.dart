import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/contactListTile.dart';
import 'package:normandy_app/src/business_contacts/contactsClass.dart';

var sampleContacts = [
  Contact(
    anniversary: '2023-05-15',
    birthday: '1990-10-25',
    businessCity: 'New York',
    businessCountryRegion: 'USA',
    businessPhone: '+1-123-456-7890',
    businessPostalCode: '10001',
    businessState: 'NY',
    businessStreet: '123 Business St',
    company: 'ABC Inc.',
    emailAddress: 'john.doe@example.com',
    emailDisplayName: 'John Doe',
    emailType: 'Work',
    firstName: 'John',
    gender: 'Male',
    initials: 'JD',
    jobTitle: 'Software Engineer',
    lastName: 'Doe',
    notes: 'Some notes about John Doe',
    priority: 'High',
    private: 'Some private data',
    sensitivity: 'Confidential',
    categories: 'Category1, Category2',
    activeTrade: true,
    active: true,
    id: '1',
  ),
  Contact(
    anniversary: '2024-02-28',
    birthday: '1985-07-12',
    businessCity: 'San Francisco',
    businessCountryRegion: 'USA',
    businessPhone: '+1-987-654-3210',
    businessPostalCode: '94105',
    businessState: 'CA',
    businessStreet: '456 Tech Ave',
    company: 'XYZ Corp.',
    emailAddress: 'jane.smith@example.com',
    emailDisplayName: 'Jane Smith',
    emailType: 'Work',
    firstName: 'Jane',
    gender: 'Female',
    initials: 'JS',
    jobTitle: 'Product Manager',
    lastName: 'Smith',
    notes: 'Some notes about Jane Smith',
    priority: 'Medium',
    private: 'Some private details',
    sensitivity: 'Internal',
    categories: 'Category2, Category3',
    activeTrade: false,
    active: true,
    id: '2',
  ),
];

class BusinessContactsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: sampleContacts.length,
        itemBuilder: (context, index) {
          return ContactTile(contact: sampleContacts[index], index: index);
        })
    );
  }
}