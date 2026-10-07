import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ui/features/weather/data/datasources/weather_local_datasource_impl.dart';
import 'package:ui/features/weather/data/repositories/weather_repository.dart';
import 'package:ui/features/weather/domain/repositories/weather_repository.dart';

import 'app.dart';
import 'features/weather/presentation/cubit/weather_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reads .env (declared as a pubspec asset) → dotenv.env['OWM_KEY'].
  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  final watchlistBox = await Hive.openBox<List<dynamic>>('watchlistBox');
  final weatherCacheBox = await Hive.openBox<Map<dynamic, dynamic>>(
    'weatherCacheBox',
  );
  final settingsBox = await Hive.openBox<bool>('settingsBox');

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WeatherRepository>(
          create: (_) => WeatherRepositoryImpl(
            local: WeatherLocalDatasourceImpl(
              weatherCacheBox: weatherCacheBox,
              watchlistBox: watchlistBox,
              settingsBox: settingsBox,
            ),
          ),
        ),
      ],
      child: BlocProvider(
        create: (context) =>
            WeatherCubit(context.read<WeatherRepository>())..loadWatchlist(),
        child: const WeatherApp(),
      ),
    ),
  );
}
