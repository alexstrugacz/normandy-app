
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkContactIsFavorite(
  String contactId
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> favoriteContacts = prefs.getStringList('favoriteContacts') ?? [];
  return favoriteContacts.contains(contactId);
}