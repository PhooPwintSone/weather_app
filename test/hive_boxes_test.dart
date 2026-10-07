import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ui/features/weather/data/datasources/weather_local_datasource_impl.dart';
import 'package:ui/features/weather/data/models/weather_model.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ui_hive_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test("'watchlistBox' (List<String>), 'weatherCacheBox' (raw JSON) and "
      "'settingsBox' (bool) survive a restart", () async {
    // --- first app session ---
    final watchlistBox = await Hive.openBox<List<dynamic>>('watchlistBox');
    await watchlistBox.put('cities', <String>['Yangon', 'Tokyo']);

    final cacheBox = await Hive.openBox<Map<dynamic, dynamic>>(
      'weatherCacheBox',
    );
    // Raw OpenWeatherMap JSON, keyed by the city name.
    await cacheBox.put('Yangon', <String, dynamic>{
      'main': {'temp': 30.5, 'feels_like': 33.0, 'humidity': 74},
      'weather': [
        {'main': 'Clear'},
      ],
      'wind': {'speed': 3.7},
      'sys': {'sunrise': 1735689300, 'sunset': 1735730100},
    });

    final settingsBox = await Hive.openBox<bool>('settingsBox');
    await settingsBox.put('hasSeededDefaults', true);

    await Hive.close(); // simulate app restart

    // --- second app session: values are decoded as List<dynamic>/
    // Map<dynamic, dynamic>/bool and must still be readable via `as E?`.
    final reopenedWatchlist = await Hive.openBox<List<dynamic>>('watchlistBox');
    final cities = List<String>.from(reopenedWatchlist.get('cities')!);
    expect(cities, ['Yangon', 'Tokyo']);

    final reopenedCache = await Hive.openBox<Map<dynamic, dynamic>>(
      'weatherCacheBox',
    );
    final stored = Map<String, dynamic>.from(reopenedCache.get('Yangon')!);
    final model = WeatherModel.fromJson(stored, 'Yangon');
    expect(model.city, 'Yangon');
    expect(model.temperature, 30.5);
    expect(model.condition, 'Clear');
    expect(model.feelsLike, 33.0);
    expect(model.humidity, 74);
    expect(model.windSpeed, 3.7);
    expect(
      model.sunrise,
      DateTime.fromMillisecondsSinceEpoch(1735689300 * 1000),
    );
    expect(
      model.sunset,
      DateTime.fromMillisecondsSinceEpoch(1735730100 * 1000),
    );

    final reopenedSettings = await Hive.openBox<bool>('settingsBox');
    expect(
      reopenedSettings.get('hasSeededDefaults', defaultValue: false),
      isTrue,
    );
  });

  test('removeFromWatchlist drops the city (case-insensitive)', () async {
    final datasource = await _openDatasource();

    await datasource.saveWatchlist(['Yangon', 'Tokyo']);

    await datasource.removeFromWatchlist('tokyo');

    expect(await datasource.readWatchlist(), ['Yangon']);
    // Unknown cities leave the stored list untouched.
    await datasource.removeFromWatchlist('Paris');
    expect(await datasource.readWatchlist(), ['Yangon']);
  });

  test('hasSeededDefaults defaults to false and persists once set', () async {
    final datasource = await _openDatasource();

    expect(await datasource.hasSeededDefaults(), isFalse);

    await datasource.markHasSeededDefaults();
    expect(await datasource.hasSeededDefaults(), isTrue);

    await Hive.close(); // simulate app restart

    // The flag survives the restart — defaults are never seeded twice.
    final reopened = await Hive.openBox<bool>('settingsBox');
    expect(reopened.get('hasSeededDefaults', defaultValue: false), isTrue);
  });
}

/// Opens all three boxes and wires the real datasource against them.
Future<WeatherLocalDatasourceImpl> _openDatasource() async {
  final watchlistBox = await Hive.openBox<List<dynamic>>('watchlistBox');
  final cacheBox = await Hive.openBox<Map<dynamic, dynamic>>('weatherCacheBox');
  final settingsBox = await Hive.openBox<bool>('settingsBox');
  return WeatherLocalDatasourceImpl(
    weatherCacheBox: cacheBox,
    watchlistBox: watchlistBox,
    settingsBox: settingsBox,
  );
}
