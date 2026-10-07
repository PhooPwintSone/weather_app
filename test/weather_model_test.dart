import 'package:flutter_test/flutter_test.dart';
import 'package:ui/features/weather/data/models/weather_model.dart';

void main() {
  test('parses the OpenWeatherMap JSON response', () {
    // Raw API body: main.temp → temperature, weather[0].main → condition.
    final apiJson = <String, dynamic>{
      'main': {'temp': 30.5},
      'weather': [
        {'main': 'Clear'},
      ],
    };

    final model = WeatherModel.fromJson(apiJson, 'Yangon');
    expect(model.city, 'Yangon');
    expect(model.temperature, 30.5);
    expect(model.condition, 'Clear');
  });

  test('parses the map shape Hive hands back after a restart', () {
    // Hive decodes stored maps as Map<dynamic, dynamic> with dynamic
    // nested values — the raw JSON must still parse from that.
    final decoded = <dynamic, dynamic>{
      'main': <dynamic, dynamic>{'temp': 27},
      'weather': <dynamic>[
        <dynamic, dynamic>{'main': 'Rain'},
      ],
    };

    final model = WeatherModel.fromJson(
      Map<String, dynamic>.from(decoded),
      'Tokyo',
    );
    expect(model.city, 'Tokyo');
    expect(model.temperature, 27.0);
    expect(model.condition, 'Rain');
  });
}
