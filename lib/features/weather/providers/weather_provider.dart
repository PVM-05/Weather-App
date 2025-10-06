import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/weather.dart';
import '../data/weather_repository.dart';

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
      if (weather == null) {
        _error = 'Không tìm thấy dữ liệu cho thành phố: $cityName';
        return null;
      }
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
    // Đảm bảo độ dài của _savedWeathers khớp với _savedCities
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