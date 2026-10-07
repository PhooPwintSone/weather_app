import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/features/weather/domain/repositories/weather_repository.dart';

import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._repository) : super(const WeatherInitial());

  final WeatherRepository _repository;

  static const List<String> _defaultCities = ['Yangon', 'New York'];

  Future<void> loadWatchlist() async {
    emit(const WeatherLoading());

    final List<String> cities;
    try {
      final saved = await _repository.getWatchlist();
      if (saved.isNotEmpty) {
        cities = saved;
      } else if (await _repository.hasSeededDefaults()) {
        cities = const [];
      } else {
        for (final city in _defaultCities) {
          await _repository.addToWatchlist(city);
        }
        await _repository.markHasSeededDefaults();
        cities = _defaultCities;
      }
    } catch (_) {
      if (isClosed) return;
      emit(const WeatherError(message: 'Could not load the saved cities'));
      return;
    }
    if (isClosed) return;

    if (cities.isEmpty) {
      emit(const WeatherLoaded(weatherList: []));
      return;
    }

    // 2. Offline-first: live API per city, cached JSON as the fallback.
    try {
      final weatherList = await _repository.getWeatherForCities(cities);
      if (isClosed) return;
      if (weatherList.isEmpty) {
        emit(
          const WeatherError(
            message: 'No weather data available — check your connection',
          ),
        );
        return;
      }
      emit(WeatherLoaded(weatherList: weatherList));
    } catch (error) {
      if (isClosed) return;
      emit(WeatherError(message: error.toString()));
    }
  }

  Future<void> addCity(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return;
    try {
      await _repository.addToWatchlist(trimmed);
    } catch (_) {
      if (isClosed) return;
      emit(const WeatherError(message: 'Could not save the city'));
      return;
    }
    await loadWatchlist();
  }

  Future<void> removeCity(String city) async {
    try {
      await _repository.removeFromWatchlist(city);
    } catch (_) {
      if (isClosed) return;
      emit(const WeatherError(message: 'Could not update the saved cities'));
      return;
    }
    await loadWatchlist();
  }
}
