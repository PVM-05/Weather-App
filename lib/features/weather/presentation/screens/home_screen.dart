import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import 'search_screen.dart';

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
              // Body: Danh sách WeatherCard cho địa điểm
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: weatherProvider.savedCities.isEmpty && weatherProvider.weather == null
                      ? const Center(child: Text('Không có dữ liệu thời tiết'))
                      : ListView.builder(
                    itemCount: (weatherProvider.weather != null ? 1 : 0) + weatherProvider.savedCities.length,
                    itemBuilder: (context, index) {
                      if (index == 0 && weatherProvider.weather != null) {
                        // Hiển thị thời tiết vị trí hiện tại
                        return WeatherCard(
                          weather: weatherProvider.weather,
                          cityNameOverride: weatherProvider.weather?.cityName ?? 'Vị trí hiện tại',
                        );
                      } else if (weatherProvider.savedCities.isNotEmpty) {
                        // Hiển thị thời tiết cho các thành phố đã lưu
                        final cityIndex = index - (weatherProvider.weather != null ? 1 : 0);
                        final city = weatherProvider.savedCities[cityIndex];
                        final weather = weatherProvider.savedWeathers.length > cityIndex
                            ? weatherProvider.savedWeathers[cityIndex]
                            : null;
                        return WeatherCard(
                          weather: weather,
                          cityNameOverride: city,
                        );
                      }
                      return const SizedBox.shrink(); // Tránh lỗi nếu index không hợp lệ
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

