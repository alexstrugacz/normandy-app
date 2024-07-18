
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> loadFavoriteContacts() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('favoriteContacts') ?? [];
}