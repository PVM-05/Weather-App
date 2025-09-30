import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    if (weatherProvider.weather == null) {
      return const SizedBox.shrink(); // Trả về widget rỗng nếu chưa có dữ liệu
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weatherProvider.weather!.cityName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Image.network(
              'http://openweathermap.org/img/wn/${weatherProvider.weather!.iconCode}@2x.png',
              width: 64,
              height: 64,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
            const SizedBox(height: 8),
            Text(
              '${weatherProvider.weather!.temperature}°C',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              weatherProvider.weather!.description,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Humidity: ${weatherProvider.weather!.humidity}%',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}