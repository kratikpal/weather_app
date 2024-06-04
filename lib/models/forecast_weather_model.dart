class ForecastWeatherModel {
  final String dateTime;
  final double minTemp;
  final double maxTemp;
  final String weatherIcon;

  ForecastWeatherModel({
    required this.dateTime,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherIcon,
  });

  factory ForecastWeatherModel.fromJson(Map<String, dynamic> json) {
    return ForecastWeatherModel(
      dateTime: json['dt_txt'],
      minTemp: json['main']['temp_min'].toDouble(),
      maxTemp: json['main']['temp_max'].toDouble(),
      weatherIcon: json['weather'][0]['icon'],
    );
  }
}
