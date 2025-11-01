import 'package:flappy_bird/game/menus/start_menu.dart';
import 'package:flappy_bird/core/services/high_score_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize(); // Initialize AdMob
  await HighScoreService.initialize(); // Initialize Hive
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flapper Bird',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const StartMenu(),
    );
  }
}
