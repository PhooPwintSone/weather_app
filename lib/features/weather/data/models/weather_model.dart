import '../../domain/entities/weather.dart';

/// Serializable [Weather] built from the raw OpenWeatherMap JSON response.
class WeatherModel extends Weather {
  const WeatherModel({
    required super.city,
    required super.temperature,
    required super.condition,
  });

  /// Parses an OpenWeatherMap current-weather response body:
  /// `main.temp` → [temperature], `weather[0].main` → [condition].
  factory WeatherModel.fromJson(
    Map<String, dynamic> json,
    String locationName,
  ) {
    return WeatherModel(
      city: locationName,
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'] as String,
    );
  }
}
