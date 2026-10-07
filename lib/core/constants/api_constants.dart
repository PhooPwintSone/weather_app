import 'package:flutter_dotenv/flutter_dotenv.dart';

/// OpenWeatherMap configuration.
///
/// The API key lives in the `.env` file (git-ignored), loaded once in
/// `main.dart` via flutter_dotenv before `runApp`.
abstract final class ApiConstants {
  static String get _apiKey => dotenv.env['OWM_KEY'] ?? '';

  /// Current-weather endpoint for [city] (metric units).
  static Uri currentWeatherUri(String city) => Uri.https(
    'api.openweathermap.org',
    '/data/2.5/weather',
    {'q': city, 'appid': _apiKey, 'units': 'metric'},
  );
}
