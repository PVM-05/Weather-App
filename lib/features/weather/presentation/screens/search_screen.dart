import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/weather.dart';
import '../../providers/weather_provider.dart';

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

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _cityController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _addCity(BuildContext context) async {
    final cityName = _cityController.text.trim();
    if (cityName.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập tên thành phố';
      });
      return;
    }

    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    try {
      await weatherProvider.fetchWeatherByCity(cityName);
      if (weatherProvider.error == null) {
        await weatherProvider.addCityToList(cityName);
        _cityController.clear();
        setState(() {
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = weatherProvider.error;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thành phố'),
      ),
      body: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Nhập tên thành phố',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Ví dụ: Hà Nội',
                hintStyle: const TextStyle(color: Colors.white54),
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.search, color: Colors.white),
                errorText: _errorMessage,
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (value) => _addCity(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: weatherProvider.isLoading ? null : () => _addCity(context),
              child: const Text('Thêm'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: weatherProvider.savedCities.length,
                itemBuilder: (context, index) {
                  final city = weatherProvider.savedCities[index];
                  final weather = weatherProvider.savedWeathers[index];

                  // Hiển thị "Đang tải..." nếu weather chưa có dữ liệu
                  String translatedDescription = 'Đang tải...';
                  int temp = 0;
                  if (weather != null) {
                    translatedDescription = weatherTranslations[weather.description.toLowerCase()] ??
                        weather.description;
                    temp = weather.temperature.toInt();
                  }

                  return ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.white),
                    title: Text(
                      city,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$temp°',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            weatherProvider.removeCityFromList(city);
                          },
                        ),
                      ],
                    ),
                    subtitle: Text(
                      translatedDescription,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () async {
                      // Tải lại dữ liệu thời tiết nếu cần
                      if (weather == null) {
                        await weatherProvider.fetchWeatherByCity(city);
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}