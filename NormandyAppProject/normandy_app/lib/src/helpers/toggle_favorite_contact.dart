
import 'package:shared_preferences/shared_preferences.dart';

Future<void> toggleFavoriteContact(
  String contactId
) async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> favoriteContacts = prefs.getStringList('favoriteContacts') ?? [];
  if (favoriteContacts.contains(contactId)) {
    favoriteContacts.remove(contactId);
  } else {
    favoriteContacts.add(contactId);
  }
  prefs.setStringList('favoriteContacts', favoriteContacts);
}