import 'package:equatable/equatable.dart';
import 'package:ui/features/weather/domain/entities/weather.dart';

sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

class WeatherLoaded extends WeatherState {
  const WeatherLoaded({required this.weatherList});

  /// One entry per saved city, in watchlist order.
  final List<Weather> weatherList;

  @override
  List<Object?> get props => [weatherList];
}

class WeatherError extends WeatherState {
  const WeatherError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
