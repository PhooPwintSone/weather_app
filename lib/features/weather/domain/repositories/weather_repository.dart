import '../entities/weather.dart';

abstract interface class WeatherRepository {
  Future<List<String>> getWatchlist();

  Future<void> addToWatchlist(String city);

  Future<void> removeFromWatchlist(String city);

  Future<bool> hasSeededDefaults();

  Future<void> markHasSeededDefaults();

  Future<List<Weather>> getWeatherForCities(List<String> cities);
}
