import 'package:flutter_test/flutter_test.dart';
import 'package:ui/features/weather/data/models/weather_model.dart';

void main() {
  test('parses the OpenWeatherMap JSON response', () {
    // Raw API body: main → temperature/feelsLike/humidity, weather[0].main →
    // condition, wind → windSpeed, sys → sunrise/sunset (Unix seconds).
    final apiJson = <String, dynamic>{
      'main': {'temp': 30.5, 'feels_like': 33.2, 'humidity': 78},
      'weather': [
        {'main': 'Clear'},
      ],
      'wind': {'speed': 4.6},
      'sys': {'sunrise': 1735689300, 'sunset': 1735730100},
    };

    final model = WeatherModel.fromJson(apiJson, 'Yangon');
    expect(model.city, 'Yangon');
    expect(model.temperature, 30.5);
    expect(model.condition, 'Clear');
    expect(model.feelsLike, 33.2);
    expect(model.humidity, 78);
    expect(model.windSpeed, 4.6);
    expect(
      model.sunrise,
      DateTime.fromMillisecondsSinceEpoch(1735689300 * 1000),
    );
    expect(
      model.sunset,
      DateTime.fromMillisecondsSinceEpoch(1735730100 * 1000),
    );
  });

  test('parses the map shape Hive hands back after a restart', () {
    // Hive decodes stored maps as Map<dynamic, dynamic> with dynamic
    // nested values — the raw JSON must still parse from that.
    final decoded = <dynamic, dynamic>{
      'main': <dynamic, dynamic>{'temp': 27, 'feels_like': 29, 'humidity': 80},
      'weather': <dynamic>[
        <dynamic, dynamic>{'main': 'Rain'},
      ],
      'wind': <dynamic, dynamic>{'speed': 3.1},
      'sys': <dynamic, dynamic>{'sunrise': 1735689300, 'sunset': 1735730100},
    };

    final model = WeatherModel.fromJson(
      Map<String, dynamic>.from(decoded),
      'Tokyo',
    );
    expect(model.city, 'Tokyo');
    expect(model.temperature, 27.0);
    expect(model.condition, 'Rain');
    expect(model.feelsLike, 29.0);
    expect(model.humidity, 80);
    expect(model.windSpeed, 3.1);
    expect(
      model.sunrise,
      DateTime.fromMillisecondsSinceEpoch(1735689300 * 1000),
    );
    expect(
      model.sunset,
      DateTime.fromMillisecondsSinceEpoch(1735730100 * 1000),
    );
  });
}
