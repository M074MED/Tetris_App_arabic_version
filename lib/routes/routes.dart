import 'package:flutter/material.dart';

import '../pages/game_page.dart';
import '../pages/home_page.dart';

class RouteManager {
  static const String homePage = '/';
  static const String gamePage = '/game_page';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        );

      case gamePage:
        return MaterialPageRoute(
          builder: (context) => const GamePage(),
        );

      default:
        throw const FormatException('Route not found! Check routes again!');
    }
  }
}
