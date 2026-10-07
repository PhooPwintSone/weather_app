import 'package:equatable/equatable.dart';

/// Pure domain entity: what the UI and business logic work with.
/// No Flutter, HTTP, or Hive knowledge lives here.
class Weather extends Equatable {
  const Weather({
    required this.city,
    required this.temperature,
    required this.condition,
  });

  final String city;

  /// Degrees Celsius.
  final double temperature;

  /// e.g. `Clear`, `Rain`, `Clouds` (OpenWeatherMap condition group).
  final String condition;

  @override
  List<Object?> get props => [city, temperature, condition];
}
