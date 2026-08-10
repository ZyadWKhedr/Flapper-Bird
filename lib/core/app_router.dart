import 'package:flappy_bird/game/menus/start_menu.dart';
import 'package:flappy_bird/game/pages/game_page.dart';
import 'package:flappy_bird/game/pages/splash_page.dart';
import 'package:flappy_bird/game/pages/settings_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String splash = '/';
  static const String startMenu = '/start-menu';
  static const String game = '/game';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case startMenu:
        return MaterialPageRoute(builder: (_) => const StartMenu());
      case game:
        return MaterialPageRoute(builder: (_) => const GamePage());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
