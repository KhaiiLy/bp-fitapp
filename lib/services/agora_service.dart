import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgoraService {
  Map<String, dynamic> config = {
    'serverUrl': 'https://agora-token-server-vbdu.onrender.com',
    'tokenExpiryTime': 3600
  }; // Configuration parameters
  String localUid = '';
  String channelName = '';
  bool isBroadcaster = true;

  Future<String> fetchToken(
      String uid, String channelName, bool isBroadcaster) async {
    // Set the token role,
    // use 1 for Host/Broadcaster, 2 for Subscriber/Audience
    this.isBroadcaster = isBroadcaster;
    int tokenRole = this.isBroadcaster ? 1 : 2;

    // Prepare the Url
    String url = '${config['serverUrl']}/rtc/$channelName/'
        '${tokenRole.toString()}/userAccount/$uid/'
        '?expiry=${config['tokenExpiryTime'].toString()}';

    // Send the http GET request
    final response = await http.get(Uri.parse(url));

    // Read the response
    if (response.statusCode == 200) {
      // The server returned an OK response
      // Parse the JSON.
      Map<String, dynamic> json = jsonDecode(response.body);
      String newToken = json['rtcToken'];
      // Store the channelName and uid
      this.channelName = channelName;
      localUid = uid;
      // Return the token
      print("fetched token: $newToken");
      return newToken;
    } else {
      // Throw an exception.
      throw Exception(
          'Failed to fetch a token. Make sure that your server URL is valid');
    }
  }

  void renewToken(RtcEngine? agoraEngine, String token) async {
    try {
      // Retrieve a token from the server
      token = await fetchToken(
        localUid,
        channelName,
        isBroadcaster,
      );
    } catch (e) {
      // Handle the exception
      debugPrint('Error fetching token');
      return;
    }

    // Renew the token
    agoraEngine!.renewToken(token);
    debugPrint("Token renewed");
  }
}
