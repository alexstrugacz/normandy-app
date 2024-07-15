class Customer {
  String id;
  String fname1;
  String lname1;
  String fname2;
  String lname2;
  String folderName;

  Customer({
    required this.id,
    required this.fname1,
    required this.lname1,
    required this.fname2,
    required this.lname2,
    required this.folderName
  });

  factory Customer.fromJson(dynamic json) {
    return Customer(
      id: json['_id'] ?? '',
      fname1: json['fname1'] ?? '',
      lname1: json['lname1'] ?? '',
      fname2: json['fname2'] ?? '',
      lname2: json['lname2'] ?? '' ,
      folderName: json['folderName'] ?? ''
    );
  }
}