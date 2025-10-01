import '../../../core/models/weather.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/location_service.dart';

class WeatherRepository {
  final ApiService apiService;
  final LocationService locationService;

  WeatherRepository({required this.apiService, required this.locationService});

  Future<Weather> getWeather() async {
    try {
      final position = await locationService.getCurrentLocation();
      return await apiService.fetchWeather(position.latitude, position.longitude);
    } catch (e) {
      throw Exception('Lỗi lấy dữ liệu thời tiết: $e');
    }
  }

  // Hàm mới: Lấy thời tiết theo tên thành phố
  Future<Weather> getWeatherByCity(String cityName) async {
    try {
      if (cityName.isEmpty) {
        throw Exception('Tên thành phố không được để trống');
      }
      return await apiService.fetchWeatherByCity(cityName.trim());
    } catch (e) {
      if (e.toString().contains('404')) {
        throw Exception('Không tìm thấy thành phố: $cityName');
      } else if (e.toString().contains('network')) {
        throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra lại internet.');
      } else {
        throw Exception('Lỗi khi lấy dữ liệu thời tiết cho $cityName: $e');
      }
    }
  }
}