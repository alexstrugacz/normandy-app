
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

Future<void> toggleIsFavorite(
  String id,
  String route
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> favorites = prefs.getStringList(route) ?? [];
  if (favorites.contains(id)) {
    favorites.remove(id);
  } else {
    favorites.add(id);
  }
  prefs.setStringList(route, favorites);
  if(kDebugMode) print(prefs.getStringList(route));
}