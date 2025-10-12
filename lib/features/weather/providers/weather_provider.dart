import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/weather.dart';
import '../data/weather_repository.dart';
import 'package:http/http.dart' as http;

class WeatherProvider with ChangeNotifier {
  final WeatherRepository weatherRepository;
  Weather? _weather;
  String? _error;
  bool _isLoading = false;
  StreamSubscription<Position>? _locationSubscription;
  List<String> _savedCities = [];
  List<Weather?> _savedWeathers = [];

  WeatherProvider({required this.weatherRepository}) {
    _loadSavedCities();
  }

  Weather? get weather => _weather;
  String? get error => _error;
  bool get isLoading => _isLoading;
  List<String> get savedCities => _savedCities;
  List<Weather?> get savedWeathers => _savedWeathers;

  Future<Weather?> fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await weatherRepository.getWeather();
      print('Current weather city: ${_weather?.cityName}');
      return _weather;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Weather?> fetchWeatherByCity(String cityName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final weather = await weatherRepository.getWeatherByCity(cityName);
      final index = _savedCities.indexOf(cityName);
      if (index != -1) {
        _savedWeathers[index] = weather;
      } else {
        _savedCities.add(cityName);
        _savedWeathers.add(weather);
      }
      await _saveWeathers();
      return weather;
    } catch (e) {
      _error = 'Lỗi khi tìm kiếm thành phố $cityName: ${e.toString().replaceFirst('Exception: ', '')}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = weatherRepository.locationService.getLocationStream().listen(
          (position) async {
        await fetchWeather();
      },
      onError: (e) {
        _error = 'Lỗi cập nhật vị trí: ${e.toString().replaceFirst('Exception: ', '')}';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    _savedCities = prefs.getStringList('saved_cities') ?? [];
    final savedWeathersJson = prefs.getStringList('saved_weathers') ?? [];
    _savedWeathers = savedWeathersJson
        .map((json) => Weather.fromJson(jsonDecode(json)))
        .toList();
    if (_savedWeathers.length < _savedCities.length) {
      _savedWeathers = List<Weather?>.filled(_savedCities.length, null)
        ..setRange(0, _savedWeathers.length, _savedWeathers);
    } else if (_savedWeathers.length > _savedCities.length) {
      _savedWeathers = _savedWeathers.sublist(0, _savedCities.length);
    }
    for (var city in _savedCities) {
      if (_savedWeathers[_savedCities.indexOf(city)] == null) {
        await fetchWeatherByCity(city);
      }
    }
    notifyListeners();
  }

  Future<void> addCityToList(String cityName) async {
    if (!_savedCities.contains(cityName)) {
      _savedCities.add(cityName);
      _savedWeathers.add(null);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_cities', _savedCities);
      await fetchWeatherByCity(cityName);
      notifyListeners();
    }
  }

  Future<void> removeCityFromList(String cityName) async {
    final index = _savedCities.indexOf(cityName);
    if (index != -1) {
      _savedCities.removeAt(index);
      _savedWeathers.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_cities', _savedCities);
      await _saveWeathers();
      notifyListeners();
    }
  }
  Future<List<String>> fetchCitySuggestions(String query) async {
    // Chỉ tìm kiếm khi người dùng nhập ít nhất 2 ký tự
    if (query.length < 2) {
      return [];
    }

    final url = 'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=vi&format=json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          // Tạo danh sách gợi ý dưới dạng "Tên thành phố, Tên quốc gia"
          final List<String> suggestions = (data['results'] as List)
              .map<String>((item) => "${item['name']}, ${item['admin1'] ?? ''}, ${item['country']}")
              .toList();
          return suggestions;
        }
      }
      return [];
    } catch (e) {
      // Trong trường hợp lỗi mạng hoặc lỗi phân tích cú pháp, trả về danh sách trống
      print("Lỗi khi lấy gợi ý thành phố: $e");
      return [];
    }
  }

  Future<void> _saveWeathers() async {
    final prefs = await SharedPreferences.getInstance();
    final weathersJson = _savedWeathers
        .where((w) => w != null)
        .map((w) => jsonEncode(w!.toJson()))
        .toList();
    await prefs.setStringList('saved_weathers', weathersJson);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}