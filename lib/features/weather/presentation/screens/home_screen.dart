import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import 'search_screen.dart';

// Ánh xạ mô tả thời tiết từ tiếng Anh sang tiếng Việt (tạm thời thủ công)


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    // Dịch mô tả thời tiết sang tiếng Việt
    String translatedDescription = weatherProvider.weather?.description ?? 'Đang tải...';
    if (weatherProvider.weather?.description != null) {
      translatedDescription = weatherTranslations[weatherProvider.weather!.description.toLowerCase()] ??
          weatherProvider.weather!.description; // Nếu không có bản dịch, giữ nguyên
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thời Tiết'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[900], // Màu nền tối giống hình ảnh
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weatherProvider.weather?.cityName ?? 'Đang tải...',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${weatherProvider.weather?.temperature.toInt() ?? 0}°',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translatedDescription,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chỉ số AQI ${weatherProvider.weather?.humidity ?? 0}', // Sử dụng humidity tạm thời làm AQI
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Provider.of<WeatherProvider>(context, listen: false).fetchWeather(),
        child: const Icon(Icons.my_location),
      ),
    );
  }
}