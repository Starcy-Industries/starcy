import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigManager {
  static final ConfigManager _instance = ConfigManager._internal();

  String humeApiKey = "";
  String humeAccessToken = "";
  late final String humeConfigId;

  ConfigManager._internal();

  static ConfigManager get instance => _instance;

  // WARNING! For development only. In production, the app should hit your own backend server to get an access token, using "token authentication" (see https://dev.hume.ai/docs/introduction/api-key#token-authentication)
  String fetchHumeApiKey() {
    return dotenv.env['HUME_API_KEY'] ?? "";
  }

  Future<String> fetchAccessToken() async {
    // Make a get request to dotenv.env['MY_SERVER_URL'] to get the access token
    final authUrl = dotenv.env['MY_SERVER_AUTH_URL'];
    if (authUrl == null) {
      throw Exception('Please set MY_SERVER_AUTH_URL in your .env file');
    }
    final url = Uri.parse(authUrl);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'];
    } else {
      throw Exception('Failed to load access token');
    }
  }

  Future<void> loadConfig() async {
    // Make sure to create a .env file in your root directory which mirrors the .env.example file
    // and add your API key and an optional EVI config ID.
    // await dotenv.load();

    // WARNING! For development only.
    humeApiKey = fetchHumeApiKey();

    // Uncomment this to use an access token in production.
    // humeAccessToken = await fetchAccessToken();
    humeConfigId = dotenv.env['HUME_CONFIG_ID'] ?? '';
  }
}
