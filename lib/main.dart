import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';
import '../core/services/location_service.dart';
import 'features/weather/data/weather_repository.dart';
import 'features/weather/providers/weather_provider.dart';
import 'features/weather/presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => LocationService()),
        Provider(
          create: (context) => WeatherRepository(
            apiService: context.read<ApiService>(),
            locationService: context.read<LocationService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WeatherProvider(
            weatherRepository: context.read<WeatherRepository>(),
          )..fetchWeather(), // Gọi fetchWeather ngay khi khởi động
        ),
      ],
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomeScreen(),
      ),
    );
  }
}