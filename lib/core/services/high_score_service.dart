import 'package:hive_flutter/hive_flutter.dart';

class HighScoreService {
  static const String _boxName = 'gameData';
  static const String _highScoreKey = 'highScore';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Future<void> saveHighScore(int score) async {
    final box = Hive.box(_boxName);
    final currentHighScore = box.get(_highScoreKey, defaultValue: 0);
    if (score > currentHighScore) {
      await box.put(_highScoreKey, score);
    }
  }

  static int getHighScore() {
    final box = Hive.box(_boxName);
    return box.get(_highScoreKey, defaultValue: 0);
  }
}
