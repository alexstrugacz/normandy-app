import 'package:url_launcher/url_launcher.dart';

handlePhoneCall(String phoneNumber) async {
  var url = Uri.parse("tel:${phoneNumber}");
  if(await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw "Failed to make call";
  }
}

