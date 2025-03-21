import 'dart:convert';
import 'package:http/http.dart' as http;

class TimezoneService {
  static const String _googleApiKey = "AIzaSyBFZ2qoArWdkXAAUm1Urnffa9x4Lr3ULnw";

  static Future<String> getTimezoneFromCity(String city) async {
    print("============================> getTimezoneFromCity: $city");
    try {
      // Step 1: Get coordinates from city name using Google Geocoding API
      final geocodeUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(city)}&key=$_googleApiKey',
      );
      final geocodeResponse = await http.get(geocodeUrl);

      if (geocodeResponse.statusCode != 200) {
        throw Exception("Failed to get geocode data");
      }

      final geocodeData = jsonDecode(geocodeResponse.body);
      print("Geocode Response: ${jsonEncode(geocodeData)}");

      if (geocodeData['results'] != null && geocodeData['results'].isNotEmpty) {
        final location = geocodeData['results'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];

        // Step 2: Get timezone using coordinates
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final timezoneUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/timezone/json?location=$lat,$lng&timestamp=$timestamp&key=$_googleApiKey',
        );
        final timezoneResponse = await http.get(timezoneUrl);

        if (timezoneResponse.statusCode != 200) {
          throw Exception("Failed to get timezone data");
        }

        final timezoneData = jsonDecode(timezoneResponse.body);
        print("Timezone Response: ${jsonEncode(timezoneData)}");

        if (timezoneData['timeZoneName'] != null) {
          return timezoneData['timeZoneName'];
        }
      }

      print("Fallback to device timezone: ${DateTime.now().timeZoneName}");
      // Fallback to device timezone if API calls fail
      return DateTime.now().timeZoneName;
    } catch (e) {
      print('Error fetching timezone: $e');
      return DateTime.now().timeZoneName;
    }
  }
}