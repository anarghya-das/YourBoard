import 'package:flutter/material.dart';
import 'home.dart';

void main() => runApp(MyApp()); // Main function which runs the whole application

// * Stateless widget which contains the home screen(widget) of the application -> Home
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your Board',
      theme: ThemeData(primaryColor: Colors.white, accentColor: Colors.black),
      home: Home(),
    );
  }
}
