import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/weather.dart';
import '../../providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import 'search_screen.dart';
import 'detail_screen.dart'; // Import mới

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // AppBar tùy chỉnh
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thời Tiết',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.black87, size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SearchScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Body: Danh sách WeatherCard
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: weatherProvider.savedCities.isEmpty && weatherProvider.weather == null
                      ? const Center(child: Text('Không có dữ liệu thời tiết'))
                      : ListView.builder(
                    itemCount: (weatherProvider.weather != null ? 1 : 0) + weatherProvider.savedCities.length,
                    itemBuilder: (context, index) {
                      Weather? weather;
                      String? cityNameOverride;
                      if (index == 0 && weatherProvider.weather != null) {
                        weather = weatherProvider.weather;
                        cityNameOverride = weather?.cityName ?? 'Vị trí hiện tại';
                      } else if (weatherProvider.savedCities.isNotEmpty) {
                        final cityIndex = index - (weatherProvider.weather != null ? 1 : 0);
                        cityNameOverride = weatherProvider.savedCities[cityIndex];
                        weather = weatherProvider.savedWeathers.length > cityIndex
                            ? weatherProvider.savedWeathers[cityIndex]
                            : null;
                      }
                      if (weather == null) return const SizedBox.shrink();

                      return GestureDetector( // Mới: Làm card clickable
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                weather: weather!,
                                cityName: cityNameOverride!,
                              ),
                            ),
                          );
                        },
                        child: WeatherCard(
                          weather: weather,
                          cityNameOverride: cityNameOverride,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Nút vị trí
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: () => Provider.of<WeatherProvider>(context, listen: false).fetchWeather(),
                  backgroundColor: const Color(0xFF00BCD4),
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}