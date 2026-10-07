import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/features/weather/domain/repositories/weather_repository.dart';

import 'weather_state.dart';

/// Watchlist-driven flow:
/// - [loadWatchlist] emits [WeatherLoading], reads the saved cities from the
///   Hive watchlist box, and seeds the default cities exactly once — only
///   when the list is empty AND the `hasSeededDefaults` app-settings flag is
///   false (first launch). An empty list after that means the user deleted
///   everything, so it stays empty. Then asks the repository for an
///   offline-first load: every city tries the live API first (refreshing its
///   cached JSON) and falls back to the cache when the request fails.
/// - [addCity] persists a city to the Hive watchlist box, then triggers a
///   refresh via [loadWatchlist].
/// - [removeCity] drops a city from the box, then refreshes the same way.
class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._repository) : super(const WeatherInitial());

  final WeatherRepository _repository;

  /// First-launch cities, saved to the box when the watchlist is empty and
  /// the defaults have never been seeded.
  static const List<String> _defaultCities = ['Yangon', 'New York'];

  Future<void> loadWatchlist() async {
    emit(const WeatherLoading());

    // 1. Saved cities from the Hive watchlist box.
    final List<String> cities;
    try {
      final saved = await _repository.getWatchlist();
      if (saved.isNotEmpty) {
        cities = saved;
      } else if (await _repository.hasSeededDefaults()) {
        // The user deleted every city — keep the watchlist empty.
        cities = const [];
      } else {
        // First launch — seed the defaults once, then set the flag.
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
    await loadWatchlist(); // triggers the refresh
  }

  Future<void> removeCity(String city) async {
    try {
      await _repository.removeFromWatchlist(city);
    } catch (_) {
      if (isClosed) return;
      emit(const WeatherError(message: 'Could not update the saved cities'));
      return;
    }
    await loadWatchlist(); // triggers the refresh
  }
}
