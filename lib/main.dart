import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/space_weather_dashboard.dart';

void main() {
  runApp(const SpaceWeatherApp());
}

class SpaceWeatherApp extends StatelessWidget {
  const SpaceWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '空间天气',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SpaceWeatherDashboard(),
    );
  }
}
