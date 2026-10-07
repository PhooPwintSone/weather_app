import 'package:flutter/material.dart';

/// Pill-shaped weather row for one city.
class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.city,
    required this.temperature,
    required this.icon,
    required this.backgroundColor,
  });

  final String city;
  final String temperature;
  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            city,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              Icon(icon, size: 26, color: Colors.black87),
              const SizedBox(width: 12),
              Text(
                temperature,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
