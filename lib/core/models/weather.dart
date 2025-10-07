import 'package:flutter/material.dart';

// ----------------------------------------------------------------------
// 🔹 Dự báo theo giờ
class ForecastHour {
  final String time;
  final String iconCode;
  final double temperature;
  final int humidity;

  ForecastHour({
    required this.time,
    required this.iconCode,
    required this.temperature,
    required this.humidity,
  });
}

// ----------------------------------------------------------------------
// 🔹 Dự báo theo ngày
class ForecastDay {
  final DateTime date;
  final String iconCode;
  final int humidity;
  final double minTemp;
  final double maxTemp;
  final double windSpeed;

  ForecastDay({
    required this.date,
    required this.iconCode,
    required this.humidity,
    required this.minTemp,
    required this.maxTemp,
    required this.windSpeed,
  });
}

// ----------------------------------------------------------------------
// 🔹 Lớp Weather chính
class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final int? aqi;
  final double windSpeed;
  final int? windDirection;
  final int? pressure; // ✅ Thêm áp suất
  final List<ForecastHour> hourlyForecast;
  final List<ForecastDay> dailyForecast;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    this.aqi,
    required this.windSpeed,
    this.windDirection,
    this.pressure,
    this.hourlyForecast = const [],
    this.dailyForecast = const [],
  });

  // ----------------------------------------------------------------------
  // 🔹 Tạo đối tượng Weather từ JSON
  factory Weather.fromJson(
      Map<String, dynamic> json, {
        Map<String, dynamic>? forecastJson,
        Map<String, dynamic>? aqiJson,
      }) {
    // Dự báo theo giờ (lấy 24 giờ đầu)
    final hourly = (forecastJson?['list'] as List<dynamic>? ?? [])
        .take(24)
        .map((item) {
      final dt = item['dt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000)
          : DateTime.now();
      return ForecastHour(
        time: dt.toString(),
        iconCode: item['weather'][0]['icon'] ?? '01d',
        temperature: (item['main']['temp'] as num?)?.toDouble() ?? 0.0,
        humidity: item['main']['humidity'] ?? 0,
      );
    }).toList();

    // Dự báo 5 ngày (gộp trung bình mỗi ngày)
    final dailyMap = <String, List<dynamic>>{};
    for (var item in (forecastJson?['list'] as List<dynamic>? ?? [])) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000)
          .toIso8601String()
          .split('T')[0];
      dailyMap.putIfAbsent(date, () => []).add(item);
    }

    final daily = dailyMap.entries.take(5).map((entry) {
      final dateParts = entry.key.split('-');
      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      final temps = entry.value
          .map((e) => (e['main']['temp'] as num?)?.toDouble() ?? 0.0)
          .toList();
      final windSpeeds = entry.value
          .map((e) => (e['wind']['speed'] as num?)?.toDouble() ?? 0.0)
          .toList();

      final avgWind =
      windSpeeds.isNotEmpty ? windSpeeds.reduce((a, b) => a + b) / windSpeeds.length : 0.0;

      return ForecastDay(
        date: date,
        iconCode: entry.value[0]['weather'][0]['icon'] ?? '01d',
        humidity: entry.value[0]['main']['humidity'] ?? 0,
        minTemp: temps.reduce((a, b) => a < b ? a : b),
        maxTemp: temps.reduce((a, b) => a > b ? a : b),
        windSpeed: avgWind,
      );
    }).toList();

    // Trả về đối tượng Weather
    return Weather(
      cityName: json['name'] ?? 'Không xác định',
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      description: json['weather']?[0]?['description'] ?? 'Không có mô tả',
      iconCode: json['weather']?[0]?['icon'] ?? '01d',
      humidity: json['main']?['humidity'] ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: json['wind']?['deg'] as int?,
      pressure: (json['main']?['pressure'] as num?)?.toInt() ??
          (forecastJson?['list']?[0]?['main']?['pressure'] as num?)?.toInt(),
      aqi: aqiJson?['list']?[0]?['main']?['aqi'] as int?,
      hourlyForecast: hourly,
      dailyForecast: daily,
    );
  }

  // ----------------------------------------------------------------------
  // 🔹 Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'description': description,
      'iconCode': iconCode,
      'humidity': humidity,
      'aqi': aqi,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'pressure': pressure,
      'hourlyForecast': hourlyForecast
          .map((e) => {
        'time': e.time,
        'iconCode': e.iconCode,
        'temperature': e.temperature,
        'humidity': e.humidity,
      })
          .toList(),
      'dailyForecast': dailyForecast
          .map((e) => {
        'date': e.date.toIso8601String(),
        'iconCode': e.iconCode,
        'humidity': e.humidity,
        'minTemp': e.minTemp,
        'maxTemp': e.maxTemp,
        'windSpeed': e.windSpeed,
      })
          .toList(),
    };
  }

  // ----------------------------------------------------------------------
  // 🔹 Tạo bản sao có chỉnh sửa
  Weather copyWith({
    String? cityName,
    double? temperature,
    String? description,
    String? iconCode,
    int? humidity,
    int? aqi,
    double? windSpeed,
    int? windDirection,
    int? pressure,
    List<ForecastHour>? hourlyForecast,
    List<ForecastDay>? dailyForecast,
  }) {
    return Weather(
      cityName: cityName ?? this.cityName,
      temperature: temperature ?? this.temperature,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      humidity: humidity ?? this.humidity,
      aqi: aqi ?? this.aqi,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      pressure: pressure ?? this.pressure,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
    );
  }
}
