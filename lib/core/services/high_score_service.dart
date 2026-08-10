import 'package:hive_flutter/hive_flutter.dart';

class HighScoreService {
  static const String _boxName = 'gameData';
  static const String _highScoreKey = 'highScore';
  static const String _selectedBirdKey = 'selectedBird';
  static const String _tempBirdKey = 'tempBirdSelection';
  static const String _musicEnabledKey = 'musicEnabled';
  static const String _trailAdCountKey = 'trailAdCount';
  static const String _trailUnlockedKey = 'trailUnlocked';
  static const String _trailEnabledKey = 'trailEnabled';

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

  static Future<void> resetHighScore() async {
    final box = Hive.box(_boxName);
    await box.put(_highScoreKey, 0);
  }

  static Future<void> saveSelectedBird(String birdPath) async {
    final box = Hive.box(_boxName);
    await box.put(_selectedBirdKey, birdPath);
  }

  static String getSelectedBird() {
    final box = Hive.box(_boxName);
    final tempBird = box.get(_tempBirdKey);
    if (tempBird != null) {
      return tempBird as String;
    }
    return box.get(_selectedBirdKey, defaultValue: 'birds/bird_yellow.png');
  }

  static Future<void> saveTempBird(String birdPath) async {
    final box = Hive.box(_boxName);
    await box.put(_tempBirdKey, birdPath);
  }

  static Future<void> clearTempBird() async {
    final box = Hive.box(_boxName);
    await box.delete(_tempBirdKey);
  }

  static Future<void> saveMusicEnabled(bool enabled) async {
    final box = Hive.box(_boxName);
    await box.put(_musicEnabledKey, enabled);
  }

  static bool isMusicEnabled() {
    final box = Hive.box(_boxName);
    return box.get(_musicEnabledKey, defaultValue: true);
  }

  static String getSelectedTrail() {
    final box = Hive.box(_boxName);
    return box.get('selectedTrail', defaultValue: 'none');
  }

  static Future<void> saveSelectedTrail(String trail) async {
    final box = Hive.box(_boxName);
    await box.put('selectedTrail', trail);
  }

  static int getTrailAdCount(String trail) {
    final box = Hive.box(_boxName);
    return box.get('trailAdCount_$trail', defaultValue: 0);
  }

  static Future<void> incrementTrailAdCount(String trail) async {
    final box = Hive.box(_boxName);
    final count = getTrailAdCount(trail) + 1;
    await box.put('trailAdCount_$trail', count);
    if (count >= 5) {
      await box.put('trailUnlocked_$trail', true);
    }
  }

  static bool isTrailUnlocked(String trail) {
    if (trail == 'none') return true;
    final box = Hive.box(_boxName);
    return box.get('trailUnlocked_$trail', defaultValue: false);
  }

  static int getTotalBalloons() {
    final box = Hive.box(_boxName);
    return box.get('totalBalloons', defaultValue: 0);
  }

  static Future<void> addBalloons(int amount) async {
    final box = Hive.box(_boxName);
    final current = getTotalBalloons();
    await box.put('totalBalloons', current + amount);
  }

  static Future<void> spendBalloons(int amount) async {
    final box = Hive.box(_boxName);
    final current = getTotalBalloons();
    await box.put('totalBalloons', (current - amount).clamp(0, current));
  }

  static bool isBirdSkinUnlocked(String birdPath) {
    if (birdPath == 'birds/bird_yellow.png') return true;
    final box = Hive.box(_boxName);
    return box.get('birdUnlocked_$birdPath', defaultValue: false);
  }

  static Future<void> unlockBirdSkin(String birdPath) async {
    final box = Hive.box(_boxName);
    await box.put('birdUnlocked_$birdPath', true);
  }
}
