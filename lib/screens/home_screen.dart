import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_app/constants/api_key.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/providers/latitude_longitude_provider.dart';
import 'package:weather_app/screens/search_screen.dart';
import 'package:weather_app/widgets/forecast_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Weather? _currentWeather;

  // Api call for current weather
  Future<Weather?> fetchWeatherData(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        final data = jsonDecode(response.body);

        // Create an instance of Weather from the parsed JSON
        return Weather.fromJson(data);
      } else {
        // If the call was not successful, throw an error
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    Weather? weather = await fetchWeatherData(lat, lon);

    setState(() {
      _currentWeather = weather;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather(37.1289771, -84.0832646);
  }

  @override
  Widget build(BuildContext context) {
    final latitudeLongitude = ref.watch(latitudeLongitudeProvider);

    // Fetch weather data when the latitude and longitude change
    _fetchWeather(latitudeLongitude[0], latitudeLongitude[1]);

    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: _currentWeather == null
            ? const CircularProgressIndicator()
            : Container(
                height: size.height,
                width: size.height,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.01,
                                horizontal: size.width * 0.05,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    child: Text(
                                      'Weather App',
                                      style: GoogleFonts.questrial(
                                        color: isDarkMode
                                            ? Colors.white
                                            : const Color(0xff1D1617),
                                        fontSize: size.height * 0.02,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        FontAwesomeIcons.searchengin),
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) {
                                        return SearchScreen(
                                          isDarkMode: isDarkMode,
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: size.height * 0.03,
                              ),
                              child: Align(
                                child: Text(
                                  _currentWeather!.cityName,
                                  style: GoogleFonts.questrial(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: size.height * 0.06,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: size.height * 0.005,
                              ),
                              child: Align(
                                child: Text(
                                  'Today', //day
                                  style: GoogleFonts.questrial(
                                    color: isDarkMode
                                        ? Colors.white54
                                        : Colors.black54,
                                    fontSize: size.height * 0.035,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: size.height * 0.03,
                              ),
                              child: Align(
                                child: Text(
                                  '${_currentWeather!.currTemp}˚C', //current temperature
                                  style: GoogleFonts.questrial(
                                    color: _currentWeather!.currTemp <= 0
                                        ? Colors.blue
                                        : _currentWeather!.currTemp > 0 &&
                                                _currentWeather!.currTemp <= 15
                                            ? Colors.indigo
                                            : _currentWeather!.currTemp > 15 &&
                                                    _currentWeather!.currTemp <
                                                        30
                                                ? Colors.deepPurple
                                                : Colors.pink,
                                    fontSize: size.height * 0.13,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.25),
                              child: Divider(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: size.height * 0.005,
                              ),
                              child: Align(
                                child: Text(
                                  _currentWeather!.mainWeather, // weather
                                  style: GoogleFonts.questrial(
                                    color: isDarkMode
                                        ? Colors.white54
                                        : Colors.black54,
                                    fontSize: size.height * 0.03,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: size.height * 0.03,
                                bottom: size.height * 0.01,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${_currentWeather!.minTemp}˚C', // min temperature
                                    style: GoogleFonts.questrial(
                                      color: _currentWeather!.minTemp <= 0
                                          ? Colors.blue
                                          : _currentWeather!.minTemp > 0 &&
                                                  _currentWeather!.minTemp <= 15
                                              ? Colors.indigo
                                              : _currentWeather!.minTemp > 15 &&
                                                      _currentWeather!.minTemp <
                                                          30
                                                  ? Colors.deepPurple
                                                  : Colors.pink,
                                      fontSize: size.height * 0.03,
                                    ),
                                  ),
                                  Text(
                                    '/',
                                    style: GoogleFonts.questrial(
                                      color: isDarkMode
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontSize: size.height * 0.03,
                                    ),
                                  ),
                                  Text(
                                    '${_currentWeather!.maxTemp}˚C', //max temperature
                                    style: GoogleFonts.questrial(
                                      color: _currentWeather!.maxTemp <= 0
                                          ? Colors.blue
                                          : _currentWeather!.maxTemp > 0 &&
                                                  _currentWeather!.maxTemp <= 15
                                              ? Colors.indigo
                                              : _currentWeather!.maxTemp > 15 &&
                                                      _currentWeather!.maxTemp <
                                                          30
                                                  ? Colors.deepPurple
                                                  : Colors.pink,
                                      fontSize: size.height * 0.03,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.05,
                                vertical: size.height * 0.02,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: Colors.white.withOpacity(0.05),
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: size.height * 0.02,
                                          left: size.width * 0.03,
                                        ),
                                        child: Text(
                                          'Forecast',
                                          style: GoogleFonts.questrial(
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: size.height * 0.025,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.all(size.width * 0.005),
                                      child: ForecastWidget(
                                        isDarkMode: isDarkMode,
                                        lat: latitudeLongitude[0],
                                        lon: latitudeLongitude[1],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
