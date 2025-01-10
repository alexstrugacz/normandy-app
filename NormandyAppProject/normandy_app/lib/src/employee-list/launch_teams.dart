import 'package:url_launcher/url_launcher.dart';

handleLaunchTeamsCall(String email) async {
  var url = Uri.parse("https://teams.microsoft.com/l/call/0/0?users=$email");
  if (await canLaunchUrl(url)) {
    // if this doesn't work, try LaunchMode.externalNonWebApplication
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw "Failed to make call";
  }
}

handleLaunchTeamsMessage(String email) async {
  var url = Uri.parse("https://teams.microsoft.com/l/chat/0/0?users=$email");
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw "Failed to make call";
  }
}
