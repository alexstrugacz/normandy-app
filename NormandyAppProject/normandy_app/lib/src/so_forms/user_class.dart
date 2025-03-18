class User {
  String? id; // Equivalent to MongoDB's _id field
  String? displayName;
  int? employeeNumber;
  String? firstName;
  String? lastName;
  String? userId;
  String? designerType;
  String? dbAccessLevel;
  bool? active;
  String email;
  String? managerId;
  String occupation;
  String department;
  String passwordHash;
  int? annualApptGoal;
  int? monthlyApptGoal;
  String? graphId;
  String? deltaLink;

  User({
    this.id,
    this.displayName,
    this.employeeNumber,
    this.firstName,
    this.lastName,
    this.userId,
    this.designerType,
    this.dbAccessLevel,
    this.active,
    required this.email,
    this.managerId,
    required this.occupation,
    required this.department,
    required this.passwordHash,
    this.annualApptGoal,
    this.monthlyApptGoal,
    this.graphId,
    this.deltaLink,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      displayName: json['displayName'] ?? '',
      employeeNumber: json['employeeNumber'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      userId: json['userId'] ?? 0,
      designerType: json['designerType'] ?? '',
      dbAccessLevel: json['dbAccessLevel'] ?? '',
      active: json['active'] ?? '',
      email: json['email'] ?? '',
      managerId: json['managerId'] ?? '',
      occupation: json['occupation'] ?? '',
      department: json['department'] ?? '',
      passwordHash: json['passwordHash'] ?? '',
      annualApptGoal: json['annualApptGoal'] ?? 0,
      monthlyApptGoal: json['monthlyApptGoal']?? 0,
      graphId: json['graphId'] ?? '',
      deltaLink: json['deltaLink'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'displayName': displayName,
      'employeeNumber': employeeNumber,
      'firstName': firstName,
      'lastName': lastName,
      'userId': userId,
      'designerType': designerType,
      'dbAccessLevel': dbAccessLevel,
      'active': active,
      'email': email,
      'managerId': managerId,
      'occupation': occupation,
      'department': department,
      'passwordHash': passwordHash,
      'annualApptGoal': annualApptGoal,
      'monthlyApptGoal': monthlyApptGoal,
      'graphId': graphId,
      'deltaLink': deltaLink,
    };
  }
}
