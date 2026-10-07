import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ui/features/weather/domain/entities/weather.dart';

import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../widgets/weather_card.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  static const List<Color> _cardColors = [
    Color(0xFFE8F5E9), // light mint
    Color(0xFFFFF9C4), // light yellow
    Color(0xFFFCE4EC), // light pink
    Color(0xFFFF7043), // vibrant orange
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: BlocBuilder<WeatherCubit, WeatherState>(
            builder: (context, state) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  // Pill-shaped header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Text(
                      'Weather',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(child: Center(child: _body(context, state))),
                  // Add-city button
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.grey),
                      onPressed: () => _promptForCity(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, WeatherState state) {
    return switch (state) {
      WeatherLoading() => const CircularProgressIndicator(),
      WeatherLoaded(:final weatherList) => _loaded(weatherList),
      WeatherError(:final message) => _error(context, message),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _loaded(List<Weather> weatherList) {
    if (weatherList.isEmpty) {
      // Loaded but empty (the user deleted every city): friendly hint
      // instead of a blank screen. Inherits the app's SanFrancisco font.
      return Center(
        child: Text(
          'No cities yet. Tap + to add one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: weatherList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final weather = weatherList[index];
              return Dismissible(
                key: Key(weather.city),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    // Matches the cards' rounded corners.
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) =>
                    context.read<WeatherCubit>().removeCity(weather.city),
                child: WeatherCard(
                  city: weather.city,
                  temperature: '${weather.temperature.round()}°',
                  icon: _iconFor(weather.condition),
                  // Cycle the pastel palette by the list index.
                  backgroundColor: _cardColors[index % _cardColors.length],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _error(BuildContext context, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.read<WeatherCubit>().loadWatchlist(),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Future<void> _promptForCity(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        // Kill M3's default purple (cursor, selection handles/highlight).
        return Theme(
          data: Theme.of(dialogContext).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionHandleColor: Colors.black,
              selectionColor: Color(0x33000000),
            ),
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.black, width: 1.5),
            ),
            title: const Text(
              'Add city',
              style: TextStyle(color: Colors.black),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'City name',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
              ),
              onSubmitted: (_) => _submitCity(dialogContext, controller),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _submitCity(dialogContext, controller),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: _cardColors[0], // pastel like the cards
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Search'),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
  }

  /// Reads the entered city, tells the Cubit, then closes the dialog.
  void _submitCity(
    BuildContext dialogContext,
    TextEditingController controller,
  ) {
    final cityName = controller.text.trim();
    if (cityName.isEmpty) return;
    dialogContext.read<WeatherCubit>().addCity(cityName);
    Navigator.of(dialogContext).pop();
  }

  static IconData _iconFor(String condition) {
    return switch (condition.toLowerCase()) {
      'clear' => Icons.wb_sunny_outlined,
      'rain' || 'drizzle' || 'thunderstorm' => Icons.water_drop_outlined,
      'snow' => Icons.ac_unit,
      'mist' || 'fog' || 'haze' || 'smoke' => Icons.cloud_outlined,
      _ => Icons.cloud_queue,
    };
  }
}
