import 'package:hive_flutter/hive_flutter.dart';
import 'package:ui/core/error/exceptions.dart';

import 'weather_local_datasource.dart';

class WeatherLocalDatasourceImpl implements WeatherLocalDatasource {
  WeatherLocalDatasourceImpl({
    required this.weatherCacheBox,
    required this.watchlistBox,
    required this.settingsBox,
  });

  final Box<Map<dynamic, dynamic>> weatherCacheBox;
  final Box<List<dynamic>> watchlistBox;
  final Box<bool> settingsBox;

  static const String _watchlistKey = 'cities';
  static const String _seededKey = 'hasSeededDefaults';

  // --- weather cache (raw API JSON, keyed by city name) ---

  @override
  Future<void> saveWeather(String city, Map<String, dynamic> json) =>
      weatherCacheBox.put(city, json);

  @override
  Future<Map<String, dynamic>?> readWeather(String city) async {
    final cached = weatherCacheBox.get(city);
    if (cached == null) return null;
    try {
      return Map<String, dynamic>.from(cached);
    } catch (error) {
      throw CacheException('Cached weather for "$city" is unreadable ($error)');
    }
  }

  // --- watchlist ---

  @override
  Future<List<String>> readWatchlist() async {
    final stored = watchlistBox.get(_watchlistKey);
    if (stored == null) return const [];
    try {
      return List<String>.from(stored);
    } catch (error) {
      throw CacheException('Saved city list is unreadable ($error)');
    }
  }

  @override
  Future<void> saveWatchlist(List<String> cities) =>
      watchlistBox.put(_watchlistKey, cities);

  @override
  Future<void> removeFromWatchlist(String city) async {
    final cities = await readWatchlist();
    final updated = cities
        .where((saved) => saved.toLowerCase() != city.toLowerCase())
        .toList();
    // Only write back when something actually matched.
    if (updated.length != cities.length) {
      await saveWatchlist(updated);
    }
  }

  // --- app settings ---

  @override
  Future<bool> hasSeededDefaults() async =>
      settingsBox.get(_seededKey, defaultValue: false) ?? false;

  @override
  Future<void> markHasSeededDefaults() => settingsBox.put(_seededKey, true);
}
