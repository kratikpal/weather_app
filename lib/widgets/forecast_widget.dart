import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/constants/api_key.dart';
import 'package:weather_app/models/daily_weather_model.dart';
import 'package:weather_app/models/forecast_weather_model.dart';

class ForecastWidget extends StatefulWidget {
  final bool isDarkMode;
  final double lat;
  final double lon;
  const ForecastWidget({
    super.key,
    required this.isDarkMode,
    required this.lat,
    required this.lon,
  });

  @override
  State<ForecastWidget> createState() => _ForecastWidgetState();
}

class _ForecastWidgetState extends State<ForecastWidget> {
  List<ForecastWeatherModel>? weatherDataList;
  List<DailyWeatherModel>? dailyWeatherList;

  Future<List<ForecastWeatherModel>> fetchWeatherData(
      double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> list = jsonResponse['list'];
      return list.map((data) => ForecastWeatherModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  void _createNewList() {
    // Map to store daily weather data
    Map<String, DailyWeatherModel> dailyWeatherMap = {};

    // Iterate through weatherDataList
    weatherDataList?.forEach((weather) {
      // Extract date without time
      String date = weather.dateTime.split(' ')[0];

      // Check if the date already exists in dailyWeatherMap
      if (dailyWeatherMap.containsKey(date)) {
        // Update high and low temperatures if needed
        DailyWeatherModel dailyWeather = dailyWeatherMap[date]!;
        if (weather.maxTemp > dailyWeather.highTemperature) {
          dailyWeather.highTemperature = weather.maxTemp;
        }
        if (weather.minTemp < dailyWeather.lowTemperature) {
          dailyWeather.lowTemperature = weather.minTemp;
        }
      } else {
        // If the date doesn't exist, create a new entry
        dailyWeatherMap[date] = DailyWeatherModel(
          day: date,
          highTemperature: weather.maxTemp,
          lowTemperature: weather.minTemp,
        );
      }
    });

    // Convert the map values to a list
    setState(() {
      dailyWeatherList = dailyWeatherMap.values.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData(widget.lat, widget.lon).then((data) {
      setState(() {
        weatherDataList = data;
        _createNewList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: dailyWeatherList != null
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailyWeatherList!.length,
              itemBuilder: (context, index) {
                final item = dailyWeatherList![index];
                return Container(
                  height: 60,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode ? Colors.black : Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.day,
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${item.highTemperature.toString()}˚C',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            item.lowTemperature.toString(),
                            style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
