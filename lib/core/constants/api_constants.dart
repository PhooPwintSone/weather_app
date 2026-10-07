import 'package:flutter_dotenv/flutter_dotenv.dart';

/// OpenWeatherMap configuration.

abstract final class ApiConstants {
  static String get _apiKey => dotenv.env['OWM_KEY'] ?? '';

  static Uri currentWeatherUri(String city) => Uri.https(
    'api.openweathermap.org',
    '/data/2.5/weather',
    {'q': city, 'appid': _apiKey, 'units': 'metric'},
  );
}
