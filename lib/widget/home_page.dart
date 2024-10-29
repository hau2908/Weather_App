// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:weather_app/Models/constants.dart';
import 'package:weather_app/Models/district.dart';
import 'package:weather_app/widget/weather_enum.dart';

import 'weather_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  Constants myConstants = Constants();

  int temperature = 0;
  int maxTemp = 0;
  String weatherStateName = 'Loading..';
  int humidity = 0;
  int windSpeed = 0;
  var currentDate = 'Loading..';
  String imageUrl = '';
  String location = 'Đà nẵng';

  List<dynamic> forecastDays = [];
  List<dynamic> consolidatedWeatherList = [];

  var selectedCities = District.getSelectedCities();
  List<String> cities = ['Đà nẵng'];
  String? errorMessage;

  final String baseUrl =
      'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/';
  final String apiKey = 'YCVZZSMMKNN59RN74H9VEQDH4';

  // Hàm tìm kiếm và lấy thông tin vị trí
  Future<void> fetchLocation(String location) async {
    setState(() {
      errorMessage = null;
    });
    await fetchWeatherData(location);
  }

  // Hàm lấy dữ liệu thời tiết từ API cho vị trí đã chọn
  Future<void> fetchWeatherData(String location) async {
    var response = await http.get(Uri.parse(
        '$baseUrl$location?unitGroup=metric&key=$apiKey&contentType=json'));
    var result = json.decode(response.body);
    var consolidateWeather = result['days'];

    setState(() {
      for (int i = 0; i < 7; i++) {
        consolidateWeather.add(consolidateWeather[i]);
      }
      temperature = consolidateWeather[0]['temp'].round();
      print(temperature);
      weatherStateName = consolidateWeather[0]['conditions'];
      print(weatherStateName);
      maxTemp = consolidateWeather[0]['tempmax'].round();
      print(maxTemp);
      humidity = consolidateWeather[0]['humidity'].round();
      print(humidity);
      windSpeed = consolidateWeather[0]['windspeed'].round();
      print(windSpeed);

      var myDate = DateTime.parse(consolidateWeather[0]['datetime']);
      currentDate = DateFormat('EEEE, d MMMM').format(myDate);

      consolidatedWeatherList = consolidateWeather.toSet().toList();

      //Duyệt tùng phần tử.
      final listWeatherState = weatherStateName.split(',');
      log(listWeatherState.toString());

      final listEnumState = listWeatherState
          .map((element) => WeatherState.getEnumFromCode(element.trim()))
          .toList();
      log(listEnumState.toString());

      String weatherImg(List<WeatherState> states) {
        if (listEnumState.contains(WeatherState.rain) &&
            listEnumState.contains(WeatherState.partiallyCloudy)) {
          return 'heavyrain';
        }

        if (listEnumState.contains(WeatherState.rain) &&
            listEnumState.contains(WeatherState.overcast)) {
          return 'lightrain';
        }

        if (listEnumState.contains(WeatherState.rain)) {
          return 'heavyrain';
        }
        return '';
      }

      imageUrl = weatherImg(listEnumState);

      consolidatedWeatherList = consolidateWeather.toSet().toList();
    });
  }

  @override
  void initState() {
    fetchLocation(cities[0]);
    fetchWeatherData(cities[0]);

    for (int i = 0; i < selectedCities.length; i++) {
      cities.add(selectedCities[i].city);
    }
    super.initState();
  }

  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffABCFF2), Color(0xff9AC6F3)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.blue,
        elevation: 0.0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.asset(
                  'assets/profile.png',
                  width: 40,
                  height: 40,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/pin.png',
                    width: 20,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  DropdownButtonHideUnderline(
                    ///**
                    child: DropdownButton(
                        value: location,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: cities.map((String location) {
                          return DropdownMenuItem(
                              value: location, child: Text(location));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            location = newValue!;
                            fetchLocation(location);
                            fetchWeatherData(location);
                          });
                        }),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
            Text(
              currentDate,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              width: size.width,
              height: 200,
              decoration: BoxDecoration(
                color: myConstants.primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: myConstants.primaryColor.withOpacity(.5),
                    offset: const Offset(0, 25),
                    blurRadius: 10,
                    spreadRadius: -12,
                  )
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40,
                    left: 20,
                    child: imageUrl == ''
                        ? const Text('')
                        : Image.asset(
                            'assets/$imageUrl.png',
                            width: 150,
                          ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Text(
                      weatherStateName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Positioned(
                      top: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 4.8),
                            child: Text(
                              temperature.toString(),
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()..shader = linearGradient,
                              ),
                            ),
                          ),
                          Text(
                            '0',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = linearGradient,
                            ),
                          ),
                          Text(
                            'C',
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = linearGradient,
                            ),
                          )
                        ],
                      ))
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  weather_items(
                    value: windSpeed,
                    text: 'Win Speed',
                    unit: 'km/h',
                    imageUrl: 'assets/windspeed.png',
                  ),
                  weather_items(
                    value: windSpeed,
                    text: 'Humidity',
                    unit: 'C°',
                    imageUrl: 'assets/humidity.png',
                  ),
                  weather_items(
                    value: windSpeed,
                    text: 'Max Temp',
                    unit: 'C°',
                    imageUrl: 'assets/max-temp.png',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'next 7 Days',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: myConstants.primaryColor,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: consolidatedWeatherList.length,
                    itemBuilder: (BuildContext context, int index) {
                      String today = DateTime.now().toString().substring(0, 10);
                      var selectedDay =
                          consolidatedWeatherList[index]['datetime'];
                      // var futureWeatherName =
                      //     consolidatedWeatherList[index]['conditions'];
                      // var weatherUrl =
                      //     futureWeatherName.replaceAll(' ', '').toLowerCase();

                      var parseDate = DateTime.parse(
                          consolidatedWeatherList[index]['datetime']);
                      var newDate =
                          DateFormat('EEE').format(parseDate).substring(0, 3);

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        margin: const EdgeInsets.only(
                            right: 20, bottom: 10, top: 10),
                        width: 80,
                        decoration: BoxDecoration(
                            color: selectedDay == today
                                ? myConstants.primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 1),
                                blurRadius: 5,
                                color: selectedDay == today
                                    ? myConstants.primaryColor
                                    : Colors.black54.withOpacity(.2),
                              ),
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              consolidatedWeatherList[index]['temp']
                                      .round()
                                      .toString() +
                                  "C",
                              style: TextStyle(
                                fontSize: 17,
                                color: selectedDay == today
                                    ? Colors.white
                                    : myConstants.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Image.asset(
                              'assets/' + imageUrl + '.png',
                              width: 30,
                            ),
                            Text(
                              newDate,
                              style: TextStyle(
                                fontSize: 17,
                                color: selectedDay == today
                                    ? Colors.white
                                    : myConstants.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
