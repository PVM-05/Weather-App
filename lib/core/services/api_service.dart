import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/weather.dart';

class ApiService {
  Future<Weather> fetchWeather(double lat, double lon) async {
    final url = '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch weather: ${response.statusCode}');
    }
  }

  // Hàm mới: Lấy thời tiết theo tên thành phố
  Future<Weather> fetchWeatherByCity(String cityName) async {
    final url = '$baseUrl/weather?q=${Uri.encodeComponent(cityName)}&appid=$apiKey&units=metric&lang=vi';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Lỗi lấy dữ liệu thời tiết cho $cityName: ${response.statusCode}');
    }
  }
  // Thêm phương thức tìm kiếm thành phố
  Future<List<String>> searchCities(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/find?q=$query&appid=$apiKey&type=like&lang=vi'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> cityList = data['list'];
      return cityList.map((city) => city['name'] as String).toList();
    } else {
      throw Exception('Lỗi tìm kiếm vị trí: ${response.statusCode}');
    }
  }
}