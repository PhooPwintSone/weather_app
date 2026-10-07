import '../entities/weather.dart';

/// Contract the data layer implements. The Cubit only ever sees this.
abstract interface class WeatherRepository {
  /// Saved list of cities from the Hive watchlist box.
  /// Throws [CacheException] when the stored list is unreadable.
  Future<List<String>> getWatchlist();

  /// Appends [city] to the watchlist (case-insensitive duplicate guard).
  Future<void> addToWatchlist(String city);

  /// Removes [city] from the saved watchlist (case-insensitive match).
  Future<void> removeFromWatchlist(String city);

  /// True once the default cities have been seeded (app-settings flag);
  /// false on first launch.
  Future<bool> hasSeededDefaults();

  /// Persists the app-settings seed flag as true.
  Future<void> markHasSeededDefaults();

  /// Offline-first weather for every city in [cities]: each city attempts a
  /// live API request first (whose raw JSON response is then cached in
  /// 'weatherCacheBox' under that city name) and falls back to the saved
  /// JSON when the request fails (SocketException, non-200, ...).
  ///
  /// Never throws for network failures — a city with neither live data nor
  /// a cache entry is simply skipped.
  Future<List<Weather>> getWeatherForCities(List<String> cities);
}
