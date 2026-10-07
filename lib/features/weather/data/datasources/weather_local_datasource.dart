/// Local source contract: Hive-backed offline storage.
abstract interface class WeatherLocalDatasource {
  // --- weather cache: city name → raw OpenWeatherMap JSON ---
  Future<void> saveWeather(String city, Map<String, dynamic> json);

  Future<Map<String, dynamic>?> readWeather(String city);

  // --- watchlist: saved List<String> of city names ---
  Future<List<String>> readWatchlist();

  Future<void> saveWatchlist(List<String> cities);

  Future<void> removeFromWatchlist(String city);

  // --- app settings ---
  /// False until the default cities have been seeded (first launch).
  Future<bool> hasSeededDefaults();

  /// Marks the default-city seed as done.
  Future<void> markHasSeededDefaults();
}
