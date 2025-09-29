import 'package:flutter/material.dart';
import '../../../core/models/weather.dart';
import '../data/weather_repository.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherRepository weatherRepository;
  Weather? _weather;
  String? _error;
  bool _isLoading = false;

  WeatherProvider({required this.weatherRepository});

  Weather? get weather => _weather;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await weatherRepository.getWeather();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}