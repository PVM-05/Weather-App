import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/weather.dart';

// Icon ảnh thời tiết
const Map<String, String> weatherImages = {
  '01d': 'assets/images/01d.png',
  '01n': 'assets/images/01n.png',
  '02d': 'assets/images/02d.png',
  '02n': 'assets/images/02n.png',
  '03d': 'assets/images/03d.png',
  '03n': 'assets/images/03n.png',
  '04d': 'assets/images/04d.png',
  '04n': 'assets/images/04n.png',
  '09d': 'assets/images/09d.png',
  '09n': 'assets/images/09n.png',
  '10d': 'assets/images/10d.png',
  '10n': 'assets/images/10n.png',
  '11d': 'assets/images/11d.png',
  '11n': 'assets/images/11n.png',
  '13d': 'assets/images/13d.png',
  '13n': 'assets/images/13n.png',
  '50d': 'assets/images/50d.png',
  '50n': 'assets/images/50n.png',
};

// --------------------------------------------------------------------------
// Giao diện chi tiết
class DetailScreen extends StatelessWidget {
  final Weather weather;
  final String cityName;

  const DetailScreen({Key? key, required this.weather, required this.cityName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chi tiết thời tiết - $cityName',
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin thành phố
            Center(
              child: Column(
                children: [
                  Text(
                    cityName,
                    style: const TextStyle(
                        fontSize: 26,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${weather.temperature.toInt()}°C',
                    style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  Text(
                    _capitalize(weather.description),
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dự báo 5 ngày
            const Text('Dự báo 5 ngày tới',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 8),
            _buildForecastCard(weather),

            const SizedBox(height: 24),

            // 4 box nhỏ: UV, Độ ẩm, Gió, Áp suất
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildInfoTile('UV', 'Yếu', '0'),
                _buildInfoTile('Độ ẩm', '${weather.humidity}%', ''),
                _buildInfoTile(
                    'Gió', '${weather.windSpeed.toStringAsFixed(1)} m/s', ''),
                _buildInfoTile('Áp suất',
                    '${weather.pressure != null ? weather.pressure.toString() : 'Không có'} hPa',
                    ''),
              ],
            ),

            const SizedBox(height: 32),

            // Box AQI (chất lượng không khí)
            const Text('Chất lượng không khí (AQI)',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 8),
            _buildAQICard(weather),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 🔹 Dự báo 5 ngày
  Widget _buildForecastCard(Weather weather) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: weather.dailyForecast.asMap().entries.map((entry) {
          final forecast = entry.value;
          final forecastDate = forecast.date;

          // Xử lý ngày
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final diff =
              DateTime(forecastDate.year, forecastDate.month, forecastDate.day)
                  .difference(today)
                  .inDays;

          String label;
          if (diff == 0) {
            label = 'Hôm nay';
          } else if (diff == 1) {
            label = 'Ngày mai';
          } else {
            label = 'Thứ ${_weekdayVN(forecastDate.weekday)}';
          }

          final icon = weatherImages[forecast.iconCode] ?? weatherImages['01d']!;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bên trái: Thứ + ngày
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd/MM').format(forecast.date),
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                // Giữa: icon
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Image.asset(
                      icon,
                      width: 55,
                      height: 55,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Phải: nhiệt độ
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${forecast.minTemp.toInt()}° / ${forecast.maxTemp.toInt()}°',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 🔹 Box AQI
  Widget _buildAQICard(Weather weather) {
    final aqiValue = weather.aqi ?? 0;
    final aqiText = _aqiText(aqiValue);
    final aqiColor = _aqiColor(aqiValue);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AQI: $aqiValue',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: aqiColor,
            ),
          ),
          Text(
            aqiText,
            style: TextStyle(
              fontSize: 18,
              color: aqiColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _aqiColor(int aqi) {
    if (aqi <= 1) return Colors.green;
    if (aqi == 2) return Colors.yellow[700]!;
    if (aqi == 3) return Colors.orange;
    if (aqi == 4) return Colors.red;
    return Colors.purple;
  }

  String _aqiText(int aqi) {
    switch (aqi) {
      case 1:
        return 'Tốt';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Kém';
      case 4:
        return 'Xấu';
      case 5:
        return 'Nguy hại';
      default:
        return 'Không có dữ liệu';
    }
  }

  // --------------------------------------------------------------------------
  // 🔹 Tiện ích
  String _capitalize(String text) =>
      text.isNotEmpty ? text[0].toUpperCase() + text.substring(1) : text;

  String _weekdayVN(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return '2';
      case DateTime.tuesday:
        return '3';
      case DateTime.wednesday:
        return '4';
      case DateTime.thursday:
        return '5';
      case DateTime.friday:
        return '6';
      case DateTime.saturday:
        return '7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }

  Widget _buildInfoTile(String title, String value, String sub) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          if (sub.isNotEmpty)
            Text(sub, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
