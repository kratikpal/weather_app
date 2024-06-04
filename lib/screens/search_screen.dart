import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/constants/api_key.dart';
import 'package:weather_app/providers/latitude_longitude_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const SearchScreen({super.key, required this.isDarkMode});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;
  String _errorMessage = '';

  Future<void> _searchCity(String cityName) async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    const limit = 5;
    final url =
        'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=$limit&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _results = data;
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error: Unable to fetch data';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define light and dark theme data
    final ThemeData lightTheme = ThemeData.light();
    final ThemeData darkTheme = ThemeData.dark();

    // Use isDarkMode to select the appropriate theme
    final ThemeData themeData = widget.isDarkMode ? darkTheme : lightTheme;
    return Theme(
      data: themeData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search City'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Enter city name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _searchCity(_controller.text);
                },
                child: const Text('Search'),
              ),
              if (_loading) const CircularProgressIndicator(),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return ListTile(
                      title: Text(result['name']),
                      subtitle:
                          Text('Lat: ${result['lat']}, Lon: ${result['lon']}'),
                      onTap: () {
                        ref
                            .read(latitudeLongitudeProvider.notifier)
                            .updateLatitude(result['lat'].toDouble(),
                                result['lon'].toDouble());

                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
