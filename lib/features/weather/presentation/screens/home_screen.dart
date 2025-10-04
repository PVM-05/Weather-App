import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import 'search_screen.dart';

// Ánh xạ mô tả thời tiết từ tiếng Anh sang tiếng Việt
final Map<String, String> weatherTranslations = {
  'clear sky': 'Trời quang đãng',
  'few clouds': 'Ít mây',
  'scattered clouds': 'Mây rải rác',
  'broken clouds': 'Mây phân tán',
  'overcast clouds': 'Nhiều mây',
  'light rain': 'Mưa nhẹ',
  'moderate rain': 'Mưa vừa',
  'heavy rain': 'Mưa lớn',
  'shower rain': 'Mưa rào',
  'snow': 'Tuyết',
  'mist': 'Sương mù',
  'thunderstorm': 'Bão',
};

// Ánh xạ mô tả thời tiết sang hình ảnh tĩnh
final Map<String, String> weatherImages = {
  'clear sky': 'assets/images/clear_sky.png',
  'few clouds': 'assets/images/few_clouds.png',
  'scattered clouds': 'assets/images/few_clouds.png',
  'broken clouds': 'assets/images/overcast.png',
  'overcast clouds': 'assets/images/overcast.png',
  'light rain': 'assets/images/rain.png',
  'moderate rain': 'assets/images/rain.png',
  'heavy rain': 'assets/images/rain.png',
  'shower rain': 'assets/images/rain.png',
  'snow': 'assets/images/snow.png',
  'mist': 'assets/images/fog.png',
  'thunderstorm': 'assets/images/thunderstorm.png',
};

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
                      'Weather',
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
              // Body: Danh sách box cho địa điểm
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    itemCount: 1, // Giả định 1 địa điểm, thay bằng weatherProvider.weathers.length nếu có nhiều
                    itemBuilder: (context, index) {
                      final weather = weatherProvider.weather;
                      if (weather == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      String translatedDescription = weather.description ?? 'Đang tải...';
                      if (weather.description != null) {
                        translatedDescription = weatherTranslations[weather.description.toLowerCase()] ??
                            weather.description;
                      }

                      String imagePath = weatherImages[weather.description.toLowerCase()] ?? 'assets/images/clear_sky.png';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Cột trái: Tên địa điểm và tình trạng
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      weather.cityName ?? 'Không xác định',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      translatedDescription,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Cột phải: Biểu tượng và nhiệt độ
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Image.asset(
                                      imagePath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${weather.temperature.toInt()}°',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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