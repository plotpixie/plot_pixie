import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:plot_pixie/src/presentation/choice_swiper.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return ChoiceSwiper(title: 'Characters');
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Plot Pixie',
      routerConfig: _router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, // dark theme
      ),
      themeMode: ThemeMode.system,
      // system theme
      debugShowCheckedModeBanner: false,
    );
  }
}
