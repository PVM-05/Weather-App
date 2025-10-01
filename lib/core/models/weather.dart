class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final int? aqi; // Thêm chỉ số AQI (có thể null nếu không có dữ liệu)

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    this.aqi,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Không xác định',
      temperature: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      description: json['weather'][0]['description'] ?? 'Không có mô tả',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0,
      aqi: json['aqi'] != null ? json['aqi']['list'][0]['main']['aqi'] : null, // Ví dụ lấy AQI
    );
  }
}