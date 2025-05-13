import 'contacts_class.dart';

class UserContact {
  static Contact fromJson(dynamic json) {
    json['FirstName'] = json['firstName'];
    json['LastName'] = json['lastName'];
    json['EmailAddress'] = json['email'];
    json['EmailType'] = "EX";
    json['Company'] = "Normandy Remodeling";
    return Contact.fromJson(json);
  }
}
