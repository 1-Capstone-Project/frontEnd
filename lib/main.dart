import 'package:flutter/material.dart';
import 'package:gitmate/screens/splash_screen.dart';
import 'package:gitmate/utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: BACKGROUND_COLOR,
        fontFamily: 'NotoSans',
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
