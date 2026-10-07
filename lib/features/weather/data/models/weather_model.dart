import '../../domain/entities/weather.dart';

/// Serializable [Weather] built from the raw OpenWeatherMap JSON response.
class WeatherModel extends Weather {
  const WeatherModel({
    required super.city,
    required super.temperature,
    required super.condition,
    required super.feelsLike,
    required super.humidity,
    required super.windSpeed,
    required super.sunrise,
    required super.sunset,
  });

  /// Parses an OpenWeatherMap current-weather response body:
  /// - `main.temp` → [temperature], `weather[0].main` → [condition]
  /// - `main.feels_like` → [feelsLike], `main.humidity` → [humidity]
  /// - `wind.speed` → [windSpeed]
  /// - `sys.sunrise` / `sys.sunset` → [sunrise] / [sunset] (Unix seconds,
  ///   converted to a local [DateTime])
  ///
  /// Nested maps are indexed dynamically (not cast to
  /// `Map<String, dynamic>`) because Hive hands them back as
  /// `Map<dynamic, dynamic>` after an app restart.
  factory WeatherModel.fromJson(
    Map<String, dynamic> json,
    String locationName,
  ) {
    return WeatherModel(
      city: locationName,
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'] as String,
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      sunrise: _unixSecondsToDateTime(json['sys']['sunrise'] as num),
      sunset: _unixSecondsToDateTime(json['sys']['sunset'] as num),
    );
  }

  /// OpenWeatherMap returns Unix seconds; the app wants local [DateTime]s.
  static DateTime _unixSecondsToDateTime(num unixSeconds) =>
      DateTime.fromMillisecondsSinceEpoch(unixSeconds.toInt() * 1000);
}
