import 'dart:convert';

import 'package:http/http.dart' as http;

class AgoraApi {
  static Future<String> agoraTokenGenerator(String channelName, String role, int uid) async {
    String cloudFunctionUrl = 'https://us-central1-kingsfam-9b1f8.cloudfunctions.net/agoraTokenGenerator?channelName=$channelName&role=$role&uid=$uid';
    var res = await http.get(Uri.parse(cloudFunctionUrl));
    var data = jsonDecode(res.body);
    // log("agoraGenToken: " + data["token"]);
    return data["token"];
  }
}
