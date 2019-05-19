import 'package:flutter/material.dart';
import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your Board',
      theme: ThemeData(
          primarySwatch: MaterialColor(
        0xFFFFFFFF,
        const <int, Color>{
          50: const Color(0xFFFFFFFF),
          100: const Color(0xFFFFFFFF),
          200: const Color(0xFFFFFFFF),
          300: const Color(0xFFFFFFFF),
          400: const Color(0xFFFFFFFF),
          500: const Color(0xFFFFFFFF),
          600: const Color(0xFFFFFFFF),
          700: const Color(0xFFFFFFFF),
          800: const Color(0xFFFFFFFF),
          900: const Color(0xFFFFFFFF),
        },
      )),
      home: Home(),
    );
  }
}
