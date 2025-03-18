class Customer {
  String id;
  String fname1;
  String lname1;
  String? cellPhone1;
  String fname2;
  String lname2;
  String? cellPhone2;
  String? address;
  String? city;
  String? state;
  int? zip;
  String folderName;

  Customer({
    required this.id,
    required this.fname1,
    required this.lname1,
    this.cellPhone1,
    required this.fname2,
    required this.lname2,
    this.cellPhone2,
    this.address,
    this.city,
    this.state,
    this.zip,
    required this.folderName
  });

  factory Customer.fromJson(dynamic json) {
    return Customer(
      id: json['_id'] ?? '',
      fname1: json['fname1'] ?? '',
      lname1: json['lname1'] ?? '',
      cellPhone1: json['cellPhone1'],
      fname2: json['fname2'] ?? '',
      lname2: json['lname2'] ?? '' ,
      cellPhone2: json['cellPhone2'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zip: json['zip'],
      folderName: json['folderName'] ?? ''
    );
  }
}