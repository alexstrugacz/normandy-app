import 'package:url_launcher/url_launcher.dart';

handlePhoneCall(String phoneNumber) async {
  var url = Uri.parse("tel:$phoneNumber");
  if(await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw "Failed to make call";
  }
}

handleMessage(String phoneNumber) async {
  var url = Uri.parse("sms:$phoneNumber");
  if(await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw "Failed to open sms app";
  }
}

handleEmail(String email) async {
  var url = Uri.parse("mailto:$email");
  if(await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw "Failed to open email";
  }
}