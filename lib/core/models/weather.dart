class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final int? aqi;
  final List<ForecastHour> hourlyForecast;
  final List<ForecastDay> dailyForecast;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    this.aqi,
    this.hourlyForecast = const [],
    this.dailyForecast = const [],
  });

  factory Weather.fromJson(Map<String, dynamic> json, {Map<String, dynamic>? forecastJson}) {
    final hourly = (json['hourlyForecast'] as List<dynamic>?)
        ?.map((e) => ForecastHour(
      time: e['time'],
      iconCode: e['iconCode'],
      temperature: (e['temperature'] as num).toDouble(),
      humidity: e['humidity'],
    ))
        .toList() ??
        (forecastJson != null
            ? (forecastJson['list'] as List<dynamic>)
            .take(8)
            .map((item) => ForecastHour(
          time: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).toString(),
          iconCode: item['weather'][0]['icon'] ?? '01d',
          temperature: (item['main']['temp'] as num?)?.toDouble() ?? 0.0,
          humidity: item['main']['humidity'] ?? 0,
        ))
            .toList()
            : []);

    final daily = (json['dailyForecast'] as List<dynamic>?)
        ?.map((e) => ForecastDay(
      day: e['day'],
      iconCode: e['iconCode'],
      humidity: e['humidity'],
      minTemp: (e['minTemp'] as num).toDouble(),
      maxTemp: (e['maxTemp'] as num).toDouble(),
    ))
        .toList() ??
        (forecastJson != null
            ? () {
          final forecastList = forecastJson['list'] as List<dynamic>;
          final dailyMap = <String, List<dynamic>>{};
          for (var item in forecastList) {
            final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000)
                .toString()
                .split(' ')[0];
            dailyMap.putIfAbsent(date, () => []).add(item);
          }
          return dailyMap.entries.map((entry) {
            final temps = entry.value
                .map((e) => (e['main']['temp'] as num).toDouble())
                .toList();
            return ForecastDay(
              day: entry.key,
              iconCode: entry.value[0]['weather'][0]['icon'] ?? '01d',
              humidity: entry.value[0]['main']['humidity'] ?? 0,
              minTemp: temps.reduce((a, b) => a < b ? a : b),
              maxTemp: temps.reduce((a, b) => a > b ? a : b),
            );
          }).toList();
        }()
            : []);

    return Weather(
      cityName: json['cityName'] ?? json['name'] ?? 'Không xác định',
      temperature: (json['temperature'] ?? json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? json['weather'][0]['description'] ?? 'Không có mô tả',
      iconCode: json['iconCode'] ?? json['weather'][0]['icon'] ?? '01d',
      humidity: json['humidity'] ?? json['main']['humidity'] ?? 0,
      aqi: json['aqi'] ?? (json['aqi'] != null ? json['aqi']['list'][0]['main']['aqi'] : null),
      hourlyForecast: hourly,
      dailyForecast: daily,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'description': description,
      'iconCode': iconCode,
      'humidity': humidity,
      'aqi': aqi,
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
        'day': e.day,
        'iconCode': e.iconCode,
        'humidity': e.humidity,
        'minTemp': e.minTemp,
        'maxTemp': e.maxTemp,
      })
          .toList(),
    };
  }

  Weather copyWith({
    String? cityName,
    double? temperature,
    String? description,
    String? iconCode,
    int? humidity,
    int? aqi,
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
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
    );
  }
}

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

class ForecastDay {
  final String day;
  final String iconCode;
  final int humidity;
  final double minTemp;
  final double maxTemp;

  ForecastDay({
    required this.day,
    required this.iconCode,
    required this.humidity,
    required this.minTemp,
    required this.maxTemp,
  });
}