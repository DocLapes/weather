import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherProvider with ChangeNotifier {
  bool isLoading = false;
  Map<String, dynamic>? weatherData;
  Map<String, dynamic>? forecastData;
  bool isDarkMode = false;

  WeatherProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    String? lastCity = prefs.getString('lastCity');
    if (lastCity != null) {
      fetchWeather(lastCity);
    }
    notifyListeners();
  }

  Future<void> fetchWeather(String city) async {
    isLoading = true;
    notifyListeners();

    final apiKey = 'YOUR_API_KEY';
    final weatherUrl =
        'http://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey';
    final forecastUrl =
        'http://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&appid=$apiKey';

    try {
      final weatherResponse = await http.get(Uri.parse(weatherUrl));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (weatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
        weatherData = json.decode(weatherResponse.body);
        forecastData = json.decode(forecastResponse.body);
        _saveLastCity(city);
      } else {
        weatherData = null;
        forecastData = null;
      }
    } catch (error) {
      weatherData = null;
      forecastData = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _saveLastCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastCity', city);
  }

  void toggleTheme() async {
    isDarkMode = !isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }
}

