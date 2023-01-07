import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:http/http.dart' as http;

// Replace API_KEY with your actual API key
// ignore: constant_identifier_names
final API_KEY = dotenv.env['giphy_api_key'];

class GiphyAPI {
 static Future<GiphyGif> fetchGif(String gifId) async {
  // Make the HTTP GET request
  final response = await http.get(
    Uri.parse('https://api.giphy.com/v1/gifs/$gifId?api_key=$API_KEY'),
  );

  // If the request was successful, parse the JSON
  if (response.statusCode == 200) {
    // Use the `json` package to decode the JSON
    var data = json.decode(response.body);
    // Get the GIF data from the data
    var gifData = data['data'] as Map<String, dynamic>;
    // Convert the GIF data to a Gif object
    return GiphyGif.fromJson(gifData);
  } else {
    // If the request was not successful, throw an error
    throw Exception('Failed to load GIF');
  }
}

}