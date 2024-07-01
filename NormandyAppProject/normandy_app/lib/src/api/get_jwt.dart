import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getJwt() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt');
}
