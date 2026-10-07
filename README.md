# ui — Weather Watchlist

A small Flutter app that keeps a watchlist of cities and shows their current
weather — **offline-first**: every city tries a live [OpenWeatherMap](https://openweathermap.org/current)
request first and falls back to the last cached response when the network (or
the API key) fails.

> This app lives inside a collection of class exercises (`flutter_class`).
> The repo root is not a Flutter project — always `cd ui` before running
> `flutter` commands.

## Features

- **Watchlist of cities** — saved locally in Hive; seeded with `Yangon` and
  `New York` on first launch only (gated by a `hasSeededDefaults` settings
  flag, so a list you intentionally emptied stays empty).
- **Add a city** — the `+` button opens a custom-styled dialog (white
  `AlertDialog`, rounded black outline, stadium-shaped Cancel/Search buttons)
  that saves the city and refreshes the list.
- **Swipe to delete** — cards dismiss right-to-left over a red
  delete background; the city is removed from the box and the list refreshes.
- **Tap for details** — tapping a card opens a blurred, dark-tinted bottom
  sheet in that card's pastel color showing feels-like, humidity, wind, and
  sunrise/sunset times.
- **Offline cache** — the raw JSON of every successful response is stored per
  city name. If a request fails (`SocketException`, non-200, timeout,
  missing key), that city's cached JSON is parsed instead; a city with
  neither live data nor cache is skipped rather than crashing the UI.
- **Clear state handling** — loading spinner, error message with a Retry
  button, and an empty state ("No cities yet. Tap + to add one.").
- **Styled cards** — pastel background colors cycle by list index, with the
  icon mapped from the weather condition (sun, rain, snow, fog, …).

## Architecture

Feature-first layering with `flutter_bloc` (Cubit). The Cubit depends only on
the domain repository interface; the concrete implementation lives in the
data layer.

```
UI (weather_screen, BlocBuilder)
  → WeatherCubit            (loadWatchlist / addCity / removeCity)
    → WeatherRepository      (domain interface)
      → WeatherRepositoryImpl (data)
          ├─ http → api.openweathermap.org/data/2.5/weather
          └─ WeatherLocalDatasourceImpl → Hive boxes
```

```
lib/
├── main.dart                     # dotenv.load → open Hive boxes → DI → runApp
├── app.dart                      # MaterialApp + theme (SanFrancisco font)
├── core/
│   ├── constants/api_constants.dart   # Uri builder, reads OWM_KEY from .env
│   └── error/exceptions.dart          # NetworkException / CacheException
├── curve_ui/                     # separate curved-login UI exercise (not routed)
└── features/weather/
    ├── data/
    │   ├── datasources/          # interface + Hive-backed implementation
    │   ├── models/weather_model.dart    # fromJson → Weather
    │   └── repositories/weather_repository.dart  # WeatherRepositoryImpl
    ├── domain/
    │   ├── entities/weather.dart        # city / temperature / condition
    │   └── repositories/weather_repository.dart  # contract
    └── presentation/
        ├── cubit/                # WeatherCubit + sealed WeatherState (Equatable)
        ├── screens/weather_screen.dart
        └── widgets/weather_card.dart
```

### Hive storage

| Box                | Declared type                  | Key          | Value                              |
| ------------------ | ------------------------------ | ------------ | ---------------------------------- |
| `watchlistBox`     | `Box<List<dynamic>>`           | `cities`     | saved city names (`List<String>`)  |
| `weatherCacheBox`  | `Box<Map<dynamic, dynamic>>`   | city name    | raw OpenWeatherMap JSON            |
| `settingsBox`      | `Box<bool>`                    | `hasSeededDefaults` | first-launch seed flag       |

The list/map boxes are deliberately typed with Hive's *decoded* types:
Hive decodes stored collections as `List<dynamic>` / `Map<dynamic, dynamic>`
and `Box.get` casts with `as E?`, so tighter generics would throw after an
app restart. `WeatherLocalDatasourceImpl` converts back to the exact types at
that boundary. All three boxes are opened in `main.dart` before `runApp`.

## API key setup

The OpenWeatherMap key lives in a git-ignored `.env` file at the project root
(loaded once via `flutter_dotenv`, declared as a pubspec asset, read by
`ApiConstants`):

```
OWM_KEY=your_api_key_here
```

Create a free key at [openweathermap.org](https://home.openweathermap.org/users/sign_up)
and replace the placeholder. Without a valid key every request returns 401,
so each city falls back to its cached JSON (empty on a fresh install).
`.env` is listed in `ui/.gitignore` — never commit the real key.

## Getting started

```sh
cd ui
flutter pub get
flutter run -d chrome     # or -d web-server / an Android emulator
```

> There is no `windows/` desktop folder in this project, so plain
> `flutter run` may report "no device" on a desktop target — pass
> `-d chrome` explicitly.

Verification:

```sh
dart format .
flutter analyze
flutter test
```

## Testing

`flutter test` runs 13 tests across three files:

- **`weather_cubit_test.dart`** — fresh-data success path, cached-JSON
  fallback when the network fails, error on offline + empty cache, first-launch
  seeding (and flag set), intentionally-empty watchlist stays empty,
  `addCity` / `removeCity` persistence-then-refresh.
- **`hive_boxes_test.dart`** — all three boxes round-trip across a simulated
  app restart, case-insensitive `removeFromWatchlist`, `hasSeededDefaults`
  defaulting to `false` and persisting once set.
- **`weather_model_test.dart`** — parsing the live API payload and the map
  shape Hive hands back after a restart.

## Notes

- `lib/curve_ui/` is a standalone curved-login UI exercise; it is not routed
  from `WeatherApp`. Its header uses the `asset\images\p4.jpg` asset.
- The theme declares `fontFamily: 'SanFrancisco'` in `lib/app.dart`.
- State management here is **flutter_bloc** — other apps in this collection
  use Riverpod, GetX, or Provider; don't mix their conventions into this one.
