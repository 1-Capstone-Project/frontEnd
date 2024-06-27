import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSans',
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundColor,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.blue),
          ),
          dayPeriodBorderSide: const BorderSide(color: Colors.blue),
          dayPeriodColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? Colors.blue
                  : Colors.grey[200]!),
          dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? Colors.white
                  : Colors.blue),
          dialHandColor: Colors.blue,
          dialBackgroundColor: Colors.grey[200],
          hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? Colors.white
                  : Colors.blue),
          entryModeIconColor: Colors.blue,
          hourMinuteColor: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.primaryColor
                  : AppColors.backgroundColor),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
