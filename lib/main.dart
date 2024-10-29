import 'package:flutter/material.dart';
import 'widget/get_started.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: getStarted(),
      debugShowCheckedModeBanner: false,
    );
  }
}
