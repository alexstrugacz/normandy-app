class Contact {
  String anniversary;
  String birthday;
  String businessCity;
  String businessCountryRegion;
  String businessPhone;
  String businessPostalCode;
  String businessState;
  String businessStreet;
  String company;
  String emailAddress;
  String emailDisplayName;
  String emailType;
  String firstName;
  String gender;
  String initials;
  String jobTitle;
  String lastName;
  String notes;
  String priority;
  bool private;
  String sensitivity;
  String categories;
  bool activeTrade;
  bool active;
  String id;

  Contact({
    required this.anniversary,
    required this.birthday,
    required this.businessCity,
    required this.businessCountryRegion,
    required this.businessPhone,
    required this.businessPostalCode,
    required this.businessState,
    required this.businessStreet,
    required this.company,
    required this.emailAddress,
    required this.emailDisplayName,
    required this.emailType,
    required this.firstName,
    required this.gender,
    required this.initials,
    required this.jobTitle,
    required this.lastName,
    required this.notes,
    required this.priority,
    required this.private,
    required this.sensitivity,
    required this.categories,
    required this.activeTrade,
    required this.active,
    required this.id,
  });

  
  factory Contact.fromJson(dynamic json) {
    return Contact(
      anniversary: json['Anniversary'] ?? '',
      birthday: json['Birthday'] ?? '',
      businessCity: json['BusinessCity'] ?? '',
      businessCountryRegion: json['BusinessCountryRegion'] ?? '',
      businessPhone: json['BusinessPhone'] ?? '',
      businessPostalCode: json['BusinessPostalCode'] ?? '',
      businessState: json['BusinessState'] ?? '',
      businessStreet: json['BusinessStreet'] ?? '',
      company: json['Company'] ?? '',
      emailAddress: json['EmailAddress'] ?? '',
      emailDisplayName: json['EmailDisplayName'] ?? '',
      emailType: json['EmailType'] ?? '',
      firstName: json['FirstName'] ?? '',
      gender: json['Gender'] ?? '',
      initials: json['Initials'] ?? '',
      jobTitle: json['JobTitle'] ?? '',
      lastName: json['LastName'] ?? '',
      notes: json['Notes'] ?? '',
      priority: json['Priority'] ?? '',
      private: json['Private'] ?? false,
      sensitivity: json['Sensitivity'] ?? '',
      categories: json['Categories'] ?? '',
      activeTrade: json['ActiveTrade'] ?? false,
      active: json['Active'] ?? false,
      id: json['id'] ?? '',
    );
  }
}
