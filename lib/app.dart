import 'package:flutter/material.dart';

import 'features/weather/presentation/screens/weather_screen.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'Weather',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'SanFrancisco',
        ),
        home: const WeatherScreen(),
      ),
    );
  }
}
