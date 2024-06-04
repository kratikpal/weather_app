class Weather {
  final String cityName;
  final String mainWeather;
  final int currTemp;
  final int maxTemp;
  final int minTemp;

  Weather({
    required this.cityName,
    required this.mainWeather,
    required this.currTemp,
    required this.maxTemp,
    required this.minTemp,
  });

  // Factory constructor to create an instance from JSON
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      mainWeather: json['weather'][0]['main'],
      currTemp: (json['main']['temp'] as num).toInt(),
      maxTemp: (json['main']['temp_max'] as num).toInt(),
      minTemp: (json['main']['temp_min'] as num).toInt(),
    );
  }
}
