import 'dart:async';
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

  WeatherProvider({required this.weatherRepository}) {
    _loadSavedCities();
  }

  Weather? get weather => _weather;
  String? get error => _error;
  bool get isLoading => _isLoading;
  List<String> get savedCities => _savedCities;

  Future<Weather?> fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await weatherRepository.getWeather();
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
      _weather = await weatherRepository.getWeatherByCity(cityName);
      return _weather;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
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
    notifyListeners();
  }

  Future<void> addCityToList(String cityName) async {
    if (!_savedCities.contains(cityName)) {
      _savedCities.add(cityName);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_cities', _savedCities);
      notifyListeners();
    }
  }

  Future<void> removeCityFromList(String cityName) async {
    _savedCities.remove(cityName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_cities', _savedCities);
    notifyListeners();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}