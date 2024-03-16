import 'package:flutter/material.dart';
import 'package:plot_pixie/src/presentation/choice_swiper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plot Pixie',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, // dark theme
      ),
      themeMode: ThemeMode.system, // system theme
      home: ChoiceSwiper(title: '',),
      debugShowCheckedModeBanner: false,
    );
  }
}


