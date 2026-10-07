import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ui/core/constants/api_constants.dart';
import 'package:ui/features/weather/domain/entities/weather.dart';
import 'package:ui/features/weather/domain/repositories/weather_repository.dart';

import '../datasources/weather_local_datasource.dart';
import '../models/weather_model.dart';

/// Offline-first [WeatherRepository] for the watchlist.
///
/// For every city: `http.get(ApiConstants.currentWeatherUri(city))` inside
/// a try-catch —
/// - status 200: decode the body, map it to a [Weather], and cache the raw
///   JSON map in `weatherCacheBox` under that city name
/// - failure (SocketException, non-200, timeout, malformed body): fall back
///   to the cached JSON for that city so the UI still populates offline
class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl({required this.local});

  final WeatherLocalDatasource local;

  static const Duration _requestTimeout = Duration(seconds: 10);

  // --- watchlist ---

  @override
  Future<List<String>> getWatchlist() => local.readWatchlist();

  @override
  Future<void> addToWatchlist(String city) async {
    final cities = await local.readWatchlist();
    final alreadySaved = cities.any(
      (saved) => saved.toLowerCase() == city.toLowerCase(),
    );
    if (alreadySaved) return;
    await local.saveWatchlist([...cities, city]);
  }

  @override
  Future<void> removeFromWatchlist(String city) =>
      local.removeFromWatchlist(city);

  // --- app settings ---

  @override
  Future<bool> hasSeededDefaults() => local.hasSeededDefaults();

  @override
  Future<void> markHasSeededDefaults() => local.markHasSeededDefaults();

  // --- weather data ---

  @override
  Future<List<Weather>> getWeatherForCities(List<String> cities) async {
    final results = <Weather>[];
    for (final city in cities) {
      Weather? weather;
      try {
        final response = await http
            .get(ApiConstants.currentWeatherUri(city))
            .timeout(_requestTimeout);
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          weather = WeatherModel.fromJson(json, city);
          try {
            // Success → cache the raw JSON map under the city name.
            await local.saveWeather(city, json);
          } catch (_) {
            // A failed cache write must not fail the network read.
          }
        }
        // Non-200 → `weather` stays null → cached-JSON fallback below.
      } catch (_) {
        // SocketException / ClientException / timeout / decode failure
        // → cached-JSON fallback below.
      }

      weather ??= await _cachedWeather(city);
      if (weather != null) results.add(weather);
    }
    return results;
  }

  /// Cached raw JSON for [city], parsed — null when missing/unreadable.
  Future<Weather?> _cachedWeather(String city) async {
    try {
      final cached = await local.readWeather(city);
      return cached == null ? null : WeatherModel.fromJson(cached, city);
    } catch (_) {
      return null; // Skip this city; offline reading must never crash.
    }
  }
}
