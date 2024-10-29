import 'dart:convert';
import 'package:flutter/material.dart';
// Library
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/Models/district.dart';
// Folder
import 'package:weather_app/widget/weather_enum.dart';

class WeatherProvider extends ChangeNotifier {
  String location = '';
  String? errorMessage;
  String imageUrl = '';

  final selectedCities = District.getSelectedCities();

  // Weather State
  String weatherStateName = 'Loading...';
  int temperature = 0;
  int maxTemp = 0;
  int humidity = 0;
  int winSpeed = 0;
  var currentDate = 'Loading...';

  // List
  List<String> cities = ['Đà Nẵng'];
  List consolidateWeatherList = [];
  List forecastDays = [];

  final String baseUrl =
      'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/';
  final String apiKey = 'YCVZZSMMKNN59RN74H9VEQDH4';

  Future<void> fetchLocation(String location) async {
    errorMessage = null;
    await fetchWeatherData(location);
  }

  Future<void> fetchWeatherData(String location) async {
    try {
      // Tạo URL API
      final Uri apiUrl = Uri.parse(
          '$baseUrl${Uri.encodeFull(location)}?unitGroup=metric&key=$apiKey&contentType=json');

      final response = await http.get(apiUrl);

      // Kiểm tra mã trạng thái
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final consolidateWeather = result['days'];

        if (consolidateWeather != null && consolidateWeather.isNotEmpty) {
          temperature = consolidateWeather[0]['temp'].round();
          print('Temperature: $temperature');
          weatherStateName = consolidateWeather[0]['conditions'];
          print('Weather State: $weatherStateName');
          maxTemp = consolidateWeather[0]['tempmax'].round();
          print('Max Temp: $maxTemp');
          humidity = consolidateWeather[0]['humidity'].round();
          print('Humidity: $humidity');
          winSpeed = consolidateWeather[0]['windspeed'].round();
          print('Wind Speed: $winSpeed');

          final myDate = DateTime.parse(consolidateWeather[0]['datetime']);
          currentDate = DateFormat('yyyy-MM-dd').format(myDate);

          consolidateWeatherList = consolidateWeather.toSet().toList();

          final listWeatherState = weatherStateName.split(',');
          final listEnumState = listWeatherState
              .map((e) => WeatherState.getEnumFromCode(e.trim()))
              .toList();

          imageUrl = listEnumState.first.image;

          notifyListeners();
        }
      }
    } catch (e) {
      errorMessage = "An error occurred: $e";
      notifyListeners();
    }
  }
}
