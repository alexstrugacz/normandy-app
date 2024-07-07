import 'package:url_launcher/url_launcher.dart';

handleLaunchGoogleMaps(String address) async {
  var url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$address");
  if(await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw "Failed to make call";
  }
}