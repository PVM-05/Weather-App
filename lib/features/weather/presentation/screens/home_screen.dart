import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.error != null) {
            return Center(child: Text(provider.error!));
          } else if (provider.weather != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  provider.weather!.cityName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Image.network(
                  'http://openweathermap.org/img/wn/${provider.weather!.iconCode}@2x.png',
                  width: 64,
                  height: 64,
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.weather!.temperature}°C',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  provider.weather!.description,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Humidity: ${provider.weather!.humidity}%',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          } else {
            return const Center(child: Text('Press the button to fetch weather'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Provider.of<WeatherProvider>(context, listen: false).fetchWeather(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}