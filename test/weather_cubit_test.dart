import 'package:flutter_test/flutter_test.dart';
import 'package:ui/features/weather/domain/entities/weather.dart';
import 'package:ui/features/weather/domain/repositories/weather_repository.dart';
import 'package:ui/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:ui/features/weather/presentation/cubit/weather_state.dart';

class _FakeWeatherRepository implements WeatherRepository {
  _FakeWeatherRepository({
    List<String>? watchlist,
    List<Weather>? cached,
    this.failNetwork = false,
    this.seeded = false,
  }) : _watchlist = [...?watchlist],
       _cached = [...?cached];

  final List<String> _watchlist;
  final List<Weather> _cached;
  bool failNetwork;
  bool seeded;
  final List<List<String>> fetchCalls = [];

  @override
  Future<List<String>> getWatchlist() async => List.unmodifiable(_watchlist);

  @override
  Future<void> addToWatchlist(String city) async {
    final exists = _watchlist.any(
      (saved) => saved.toLowerCase() == city.toLowerCase(),
    );
    if (!exists) _watchlist.add(city);
  }

  @override
  Future<void> removeFromWatchlist(String city) async {
    _watchlist.removeWhere(
      (saved) => saved.toLowerCase() == city.toLowerCase(),
    );
  }

  @override
  Future<bool> hasSeededDefaults() async => seeded;

  @override
  Future<void> markHasSeededDefaults() async {
    seeded = true;
  }

  @override
  Future<List<Weather>> getWeatherForCities(List<String> cities) async {
    fetchCalls.add(cities);
    // Mirrors the real repository: live API data when the network works,
    // otherwise the cached-JSON fallback for every city.
    if (failNetwork) return _cached;
    return [
      for (final city in cities)
        Weather(city: city, temperature: 25, condition: 'Clear'),
    ];
  }
}

void main() {
  group('loadWatchlist', () {
    test('emits fresh API data for all saved cities on success', () async {
      final repo = _FakeWeatherRepository(watchlist: ['Yangon', 'Tokyo']);
      final cubit = WeatherCubit(repo);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<WeatherLoading>(),
          isA<WeatherLoaded>().having(
            (s) => s.weatherList.map((w) => w.city),
            'cities',
            ['Yangon', 'Tokyo'],
          ),
        ]),
      );
      await cubit.loadWatchlist();
      await expectation;
      await cubit.close();
    });

    test('maps cached JSON into the state when the network fails', () async {
      final repo = _FakeWeatherRepository(
        watchlist: ['Yangon'],
        cached: [
          const Weather(city: 'Yangon', temperature: 31, condition: 'Haze'),
        ],
        failNetwork: true,
      );
      final cubit = WeatherCubit(repo);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<WeatherLoading>(),
          isA<WeatherLoaded>().having(
            (s) => s.weatherList.single.city,
            'city',
            'Yangon',
          ),
        ]),
      );
      await cubit.loadWatchlist();
      await expectation;
      await cubit.close();
    });

    test('emits an error when offline with an empty cache', () async {
      final repo = _FakeWeatherRepository(
        watchlist: ['Yangon'],
        failNetwork: true,
      );
      final cubit = WeatherCubit(repo);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<WeatherLoading>(), isA<WeatherError>()]),
      );
      await cubit.loadWatchlist();
      await expectation;
      await cubit.close();
    });

    test(
      'seeds default cities on first launch and sets the seed flag',
      () async {
        final repo = _FakeWeatherRepository();
        final cubit = WeatherCubit(repo);

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<WeatherLoading>(),
            isA<WeatherLoaded>().having(
              (s) => s.weatherList.map((w) => w.city),
              'cities',
              ['Yangon', 'New York'],
            ),
          ]),
        );
        await cubit.loadWatchlist();
        await expectation;

        // The defaults were persisted to the (fake) watchlist box...
        expect(await repo.getWatchlist(), ['Yangon', 'New York']);
        // ...the seed flag is now set...
        expect(repo.seeded, isTrue);
        // ...and the cities were fetched through the repository.
        expect(repo.fetchCalls, [
          ['Yangon', 'New York'],
        ]);
        await cubit.close();
      },
    );

    test(
      'keeps an intentionally empty watchlist empty (already seeded)',
      () async {
        final repo = _FakeWeatherRepository(seeded: true);
        final cubit = WeatherCubit(repo);

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<WeatherLoading>(),
            isA<WeatherLoaded>().having(
              (s) => s.weatherList,
              'weatherList',
              isEmpty,
            ),
          ]),
        );
        await cubit.loadWatchlist();
        await expectation;

        // No reseeding, so no network calls either.
        expect(await repo.getWatchlist(), isEmpty);
        expect(repo.fetchCalls, isEmpty);
        await cubit.close();
      },
    );
  });

  group('addCity', () {
    test('persists to the watchlist then triggers a refresh', () async {
      final repo = _FakeWeatherRepository(watchlist: ['Yangon']);
      final cubit = WeatherCubit(repo);

      await cubit.addCity('Tokyo');

      expect(repo.fetchCalls, [
        ['Yangon', 'Tokyo'],
      ]);
      expect(cubit.state, isA<WeatherLoaded>());
      final loaded = cubit.state as WeatherLoaded;
      expect(loaded.weatherList.map((w) => w.city), ['Yangon', 'Tokyo']);
      await cubit.close();
    });

    test('ignores blank input', () async {
      final repo = _FakeWeatherRepository(watchlist: ['Yangon']);
      final cubit = WeatherCubit(repo);

      await cubit.addCity('   ');

      expect(repo.fetchCalls, isEmpty);
      await cubit.close();
    });
  });

  group('removeCity', () {
    test('drops the city from the watchlist then triggers a refresh', () async {
      final repo = _FakeWeatherRepository(watchlist: ['Yangon', 'Tokyo']);
      final cubit = WeatherCubit(repo);

      await cubit.removeCity('Tokyo');

      // Persisted without the removed city...
      expect(await repo.getWatchlist(), ['Yangon']);
      // ...and the UI refreshed from the updated list.
      expect(repo.fetchCalls, [
        ['Yangon'],
      ]);
      expect(cubit.state, isA<WeatherLoaded>());
      final loaded = cubit.state as WeatherLoaded;
      expect(loaded.weatherList.map((w) => w.city), ['Yangon']);
      await cubit.close();
    });
  });
}
