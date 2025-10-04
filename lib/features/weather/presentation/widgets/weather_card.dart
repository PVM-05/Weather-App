import 'package:flutter/material.dart';
import '../../../../core/models/weather.dart';

// Ánh xạ mô tả thời tiết từ tiếng Anh sang tiếng Việt
const Map<String, String> weatherTranslations = {
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

// Ánh xạ iconCode sang hình ảnh tĩnh
const Map<String, String> weatherImages = {
  '01d': 'assets/images/01d.png', // Trời quang ngày
  '01n': 'assets/images/01n.png', // Trời quang đêm
  '02d': 'assets/images/02d.png', // Ít mây ngày
  '02n': 'assets/images/02n.png', // Ít mây đêm
  '03d': 'assets/images/03d.png', // Mây rải rác ngày
  '03n': 'assets/images/03n.png', // Mây rải rác đêm
  '04d': 'assets/images/04d.png', // Mây phân tán ngày
  '04n': 'assets/images/04n.png', // Mây phân tán đêm
  '09d': 'assets/images/09d.png', // Mưa rào ngày
  '09n': 'assets/images/09n.png', // Mưa rào đêm
  '10d': 'assets/images/10d.png', // Mưa nhẹ ngày
  '10n': 'assets/images/10n.png', // Mưa nhẹ đêm
  '11d': 'assets/images/11d.png', // Bão ngày
  '11n': 'assets/images/11n.png', // Bão đêm
  '13d': 'assets/images/13d.png', // Tuyết ngày
  '13n': 'assets/images/13n.png', // Tuyết đêm
  '50d': 'assets/images/50d.png', // Sương mù ngày
  '50n': 'assets/images/50n.png', // Sương mù đêm
};

class WeatherCard extends StatelessWidget {
  final Weather? weather;
  final String? cityNameOverride;

  const WeatherCard({
    Key? key,
    required this.weather,
    this.cityNameOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final translatedDescription = weather!.description != null
        ? (weatherTranslations[weather!.description.toLowerCase()] ?? weather!.description)
        .replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase())
        : 'Đang tải...';
    final imagePath = weatherImages[weather!.iconCode] ?? 'assets/images/01d.png'; // Dùng iconCode

    return Card(
      elevation: 0, // Không shadow
      margin: const EdgeInsets.all(12), // Kích thước nhỏ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Bán kính bo tròn nhỏ
        side: const BorderSide(
          color: Colors.black,
          width: 2.0,
        ),
      ),
      color: Colors.white, // Màu nền cố định là trắng
      child: Padding(
        padding: const EdgeInsets.all(12), // Kích thước nhỏ
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Phần trái: Tên địa điểm và chi tiết tình trạng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cityNameOverride ?? weather!.cityName,
                    style: const TextStyle(
                      fontSize: 30, // Tiêu đề
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4), // Khoảng cách nhỏ
                  Text(
                    translatedDescription,
                    style: const TextStyle(
                      fontSize: 14, // Mô tả
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Phần phải: Biểu tượng thời tiết và nhiệt độ
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: 80, // Kích thước hình ảnh
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 8), // Khoảng cách giữa hình ảnh và nhiệt độ
                Text(
                  '${weather!.temperature.toInt()}°',
                  style: const TextStyle(
                    fontSize: 50, // Nhiệt độ
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}