
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkIsFavorite(
  String contactId,
  String route
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> favorites = prefs.getStringList(route) ?? [];
  return favorites.contains(contactId);
}