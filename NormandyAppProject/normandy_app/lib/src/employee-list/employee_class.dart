class Person {
  String initials;
  String ext;
  String lastName;
  String firstName;
  String cellPhone;
  String directOffice;
  String homePhone;
  String email;
  String jobTitle;
  String department;
  String homeAddress = "";
  String id;
  String microsoftId;
  bool favorite;
  String searchTerm = "";

  Person({
    required this.initials,
    required this.ext,
    required this.lastName,
    required this.firstName,
    required this.cellPhone,
    required this.directOffice,
    required this.homePhone,
    required this.email,
    required this.jobTitle,
    required this.department,
    this.homeAddress = "",
    required this.id,
    required this.microsoftId,
    required this.favorite,
  }) {
    searchTerm = _generateSearchTerm();
  }

  String _generateSearchTerm() {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else {
      return '';
    }
  }

  void updateFavorite(bool isFavorite) {
    favorite = isFavorite;
  }

  factory Person.fromJson(dynamic json) {

    String initials;
    try {
      if (json['firstName'] != null && json['lastName'] != null) {
        initials = (json['firstName'].substring(0,1) + json['lastName'].substring(0,1));
      } else if (json['firstName'] != null) {
        initials = (json['firstName'] ?? "").substring(0, 2);
      } else if (json['firstName'] != null) {
        initials = (json['firstName'] ?? "").substring(0, 2);
      } else {
        initials = "";
      }
    } catch (e) {
      initials = "";
    }

    String directOffice;
    try {
      if (json['ext'] == '') {
        directOffice = 'No direct office number';
      } else if (json['directOffice'] != '') {
        directOffice = json['directOffice'];
      } else {
        directOffice = 'No direct office number';
      }
    } catch(e) {
      directOffice = 'No direct office number';
    }


    return Person(
      initials: initials,
      ext: (json['ext'] ?? ''),
      lastName: (json['lastName'] ?? ''),
      firstName: (json['firstName'] ?? ''),
      cellPhone: (json['cellPhone'] ?? ''),
      directOffice: (directOffice),
      homePhone: (json['homePhone'] ?? ''),
      email: (json['email'] ?? ''),
      jobTitle: (json['jobTitle'] ?? ''),
      department: (json['deparpment'] ?? ''),
      homeAddress: (json['homeAddress'] ?? ''),
      id: (json['_id'] ?? ''),
      microsoftId: (json['microsoftId'] ?? ''),
      favorite: false,
    );
  }
}