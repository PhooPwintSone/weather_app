import 'package:equatable/equatable.dart';

/// Pure domain entity: what the UI and business logic work with.
/// No Flutter, HTTP, or Hive knowledge lives here.
class Weather extends Equatable {
  const Weather({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
  });

  final String city;

  /// Degrees Celsius.
  final double temperature;

  /// e.g. `Clear`, `Rain`, `Clouds` (OpenWeatherMap condition group).
  final String condition;

  /// Degrees Celsius — how warm it actually feels (`main.feels_like`).
  final double feelsLike;

  /// Percent (`main.humidity`).
  final int humidity;

  /// Metres per second (`wind.speed`, metric units).
  final double windSpeed;

  /// Sunrise instant as a local `DateTime` (`sys.sunrise`, Unix seconds).
  final DateTime sunrise;

  /// Sunset instant as a local `DateTime` (`sys.sunset`, Unix seconds).
  final DateTime sunset;

  @override
  List<Object?> get props => [
    city,
    temperature,
    condition,
    feelsLike,
    humidity,
    windSpeed,
    sunrise,
    sunset,
  ];
}
