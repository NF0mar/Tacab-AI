import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '1a1c9c5d66e294da6729e008a9f427ef';

  Future<Map<String, dynamic>> fetchFullForecast(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely&appid=$apiKey&units=metric',
      // 'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely&appid=$apiKey&units=metric&lang=so',
      // 'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely&appid=$apiKey&units=metric&lang=en'
    );

    final res = await http.get(url);

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to load weather');
    }
  }

  // Future<Map<String, dynamic>> fetchFullForecast(double lat, double lon) async {
  //   final url = Uri.parse(
  //     'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
  //   );

  //   final res = await http.get(url);

  //   if (res.statusCode == 200) {
  //     return json.decode(res.body);
  //   } else {
  //     throw Exception('Failed to load weather');
  //   }
  // }
}
