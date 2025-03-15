import 'dart:convert';
import 'package:http/http.dart' as http;

class TimezoneService {
  static const String _googleApiKey = 'AIzaSyCkM12B6BIs2XtIaxyN-bTtuADkAwWwE-Y';

  static Future<String> getTimezoneFromCity(String city) async {
    try {
      // First, get coordinates from city name using Google Geocoding API
      final geocodeUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(city)}&key=$_googleApiKey',
      );
      final geocodeResponse = await http.get(geocodeUrl);
      final geocodeData = jsonDecode(geocodeResponse.body);

      if (geocodeData['results'] != null && geocodeData['results'].isNotEmpty) {
        final location = geocodeData['results'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];

        // Then, get timezone using coordinates
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final timezoneUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/timezone/json?location=$lat,$lng&timestamp=$timestamp&key=$_googleApiKey',
        );
        final timezoneResponse = await http.get(timezoneUrl);
        final timezoneData = jsonDecode(timezoneResponse.body);

        if (timezoneData['timeZoneId'] != null) {
          return timezoneData['timeZoneId'];
        }
      }

      // Fallback to device timezone if API calls fail
      return DateTime.now().timeZoneName;
    } catch (e) {
      print('Error fetching timezone: $e');
      return DateTime.now().timeZoneName;
    }
  }
}