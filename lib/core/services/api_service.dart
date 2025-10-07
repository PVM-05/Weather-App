import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/weather.dart';

class ApiService {
  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url = '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch weather: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchWeatherByCity(String cityName) async {
    final url = '$baseUrl/weather?q=${Uri.encodeComponent(cityName)}&appid=$apiKey&units=metric&lang=vi';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi lấy dữ liệu thời tiết cho $cityName: ${response.statusCode}');
    }
  }

  Future<List<String>> searchCities(String query) async {
    if (query.isEmpty) return [];
    final url = '$baseUrl/find?q=${Uri.encodeComponent(query)}&appid=$apiKey&type=like&lang=vi&limit=10';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> cityList = data['list'] ?? [];
      return cityList.map((city) => city['name'] as String).toList();
    } else {
      throw Exception('Lỗi tìm kiếm thành phố: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchForecast(double lat, double lon) async {
    final url = '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi lấy dự báo: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchForecastByCity(String cityName) async {
    final url = '$baseUrl/forecast?q=${Uri.encodeComponent(cityName)}&appid=$apiKey&units=metric&lang=vi';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi lấy dự báo cho $cityName: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchAQI(double lat, double lon) async {
    final url = '$baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi lấy AQI: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchAQIByCity(String cityName) async {
    final url = '$baseUrl/weather?q=${Uri.encodeComponent(cityName)}&appid=$apiKey&units=metric&lang=vi';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final weatherJson = jsonDecode(response.body);
      final lat = weatherJson['coord']['lat'] as double;
      final lon = weatherJson['coord']['lon'] as double;
      return await fetchAQI(lat, lon);
    } else {
      throw Exception('Lỗi lấy tọa độ cho $cityName: ${response.statusCode}');
    }
  }
}