import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_pixie/src/presentation/bottom_navigation.dart';

import 'package:plot_pixie/src/presentation/choice_swiper.dart';
import 'package:plot_pixie/src/presentation/idea_chooser.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => BottomNavigation(child: child),
      routes: [
        GoRoute(
          path: '/',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => const IdeaChooser(),
        ),
        GoRoute(
          path: '/characters',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => ChoiceSwiper(title: 'characters'),
        ),
        GoRoute(
          path: '/outline',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => ChoiceSwiper(title: 'characters'),
        ),
      ],
    )
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
