# AGENTS.md

Offline-first Flutter weather watchlist (OpenWeatherMap + Hive). This repo root
**is** the Flutter project — run all `flutter`/`dart` commands from here.

## Critical gotchas

- **Package name is `ui`, not the folder name (`weather_app`).** All internal
  imports must be `package:ui/...`. Do not introduce `package:weather_app/...`.
- **`.env` is required and is a declared pubspec asset.** It holds
  `OWM_KEY=<key>` and is git-ignored, so a fresh checkout has none. `main.dart`
  calls `dotenv.load(fileName: ".env")` before `runApp`. Without a valid key
  every request falls back to cached JSON (empty on a fresh install). Recreate
  it as `OWM_KEY=your_key_here` if missing; never commit the real key.
- **No `windows/` desktop target.** `flutter run` alone may report "no device";
  pass `-d chrome` (or `-d web-server`, or a mobile emulator).
- `lib/curve_ui/` and the `asset/` folder were removed; do not re-add them. The
  only pubspec asset is `.env`.

## Commands

```sh
flutter pub get
flutter run -d chrome
# focused verification (run in this order)
dart format .
flutter analyze
flutter test
```

- Single test file: `flutter test test/weather_cubit_test.dart`
- Single test: `flutter test --plain-name "seeds default cities"`
- Tests never hit the network: `weather_cubit_test.dart` uses an in-file
  `_FakeWeatherRepository`; `hive_boxes_test.dart` runs against a temp dir.

## Architecture

Feature-first + `flutter_bloc` (Cubit). The Cubit depends only on the domain
repository interface; the concrete impl lives in the data layer.

```
WeatherScreen → WeatherCubit → WeatherRepository (domain interface)
  → WeatherRepositoryImpl (data) → http (api.openweathermap.org) + Hive datasource
```

- Wiring/DI happens in `lib/main.dart`: `dotenv.load` → open the 3 Hive boxes →
  `MultiRepositoryProvider` + `BlocProvider` → `runApp`.
- Layers under `lib/features/weather/`: `domain/` (entities + repo contract),
  `data/` (models, datasource, repo impl), `presentation/` (cubit/state/screen/widgets).
- `ApiConstants.currentWeatherUri(city)` reads `OWM_KEY` via dotenv and pins
  `units=metric`.

## Hive storage quirk (do not "fix" the generics)

Boxes are deliberately opened with Hive's **decoded** types:
`watchlistBox` (`Box<List<dynamic>>`, key `cities`), `weatherCacheBox`
(`Box<Map<dynamic, dynamic>>`, keyed by city name, raw OWM JSON), and
`settingsBox` (`Box<bool>`, key `hasSeededDefaults`). Hive decodes stored
collections as `List<dynamic>`/`Map<dynamic, dynamic>` and `Box.get` casts with
`as E?`, so tighter generics throw after an app restart.
`WeatherLocalDatasourceImpl` converts back to exact types at that boundary.
All three boxes are opened in `main.dart` before `runApp`.

## Conventions

- This app uses **flutter_bloc**. Other apps in the `flutter_class` collection
  use Riverpod/GetX/Provider — do not mix their patterns in here.
- `analysis_options.yaml` uses stock `flutter_lints`; no custom rules.
- Watchlist membership and dedupe are **case-insensitive** (repo + datasource).
- Defaults (`Yangon`, `New York`) are seeded once, gated by `hasSeededDefaults`,
  so an intentionally emptied watchlist stays empty. Preserve this behavior.
- Offline-first contract: live request per city, fall back to that city's cached
  JSON; skip a city with neither rather than crashing. A failed cache write must
  not fail a successful network read.
