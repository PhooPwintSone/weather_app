import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
              final cardColor = _cardColors[index % _cardColors.length];
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
                child: GestureDetector(
                  onTap: () => _showWeatherDetails(context, weather, cardColor),
                  child: WeatherCard(
                    city: weather.city,
                    temperature: '${weather.temperature.round()}°',
                    icon: _iconFor(weather.condition),
                    backgroundColor: cardColor,
                  ),
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

  /// Opens the blurred detail sheet for [weather], tinted in the tapped
  /// card's [backgroundColor].
  void _showWeatherDetails(
    BuildContext context,
    Weather weather,
    Color backgroundColor,
  ) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close details',
      // The custom blur below replaces the default colored barrier.
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, _, _) {
        return Stack(
          children: [
            // The blur: everything behind the sheet, darkened. Tap to close.
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.black.withValues(alpha: 0.2)),
                ),
              ),
            ),
            // The floating sheet, bottom-aligned inside a screen margin.
            Align(
              alignment: Alignment.bottomCenter,
              child: TweenAnimationBuilder<Offset>(
                tween: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, offset, child) =>
                    FractionalTranslation(translation: offset, child: child),
                // The dialog route has no Material ancestor, so uncolored
                // text falls back to odd default styling (red text and
                // yellow underlines). A transparent Material restores the
                // proper Material text theme for everything inside.
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle — a small thick black pill.
                        Container(
                          height: 6,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          weather.city,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weather.condition,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 2x2 detail grid.
                        Row(
                          children: [
                            Expanded(
                              child: _detailTile(
                                icon: Icons.thermostat,
                                label: 'Feels Like',
                                value: '${weather.feelsLike.round()}°',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _detailTile(
                                icon: Icons.water_drop_outlined,
                                label: 'Humidity',
                                value: '${weather.humidity}%',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _detailTile(
                                icon: Icons.air,
                                label: 'Wind',
                                value:
                                    '${weather.windSpeed.toStringAsFixed(1)} m/s',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: _sunTile(weather)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // The blur fades in/out with the route; the sheet's slide-in comes
        // from the TweenAnimationBuilder above.
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  /// One labelled stat cell of the detail sheet's 2x2 grid.
  Widget _detailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom-right grid cell: sunrise and sunset stacked vertically so both
  /// times fit the narrow cell.
  Widget _sunTile(Weather weather) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sunRow(
            icon: Icons.wb_sunny_outlined,
            label: 'Sunrise',
            time: _formatTime(weather.sunrise),
          ),
          const SizedBox(height: 10),
          _sunRow(
            icon: Icons.nights_stay_outlined,
            label: 'Sunset',
            time: _formatTime(weather.sunset),
          ),
        ],
      ),
    );
  }

  Widget _sunRow({
    required IconData icon,
    required String label,
    required String time,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// `6:12 AM` style local time for the sunrise/sunset rows.
  static String _formatTime(DateTime time) =>
      DateFormat('hh:mm a').format(time.toLocal());

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
