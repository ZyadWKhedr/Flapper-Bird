import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flappy_bird/game/menus/pause_menu.dart';
import 'package:flappy_bird/game/menus/start_menu.dart';
import 'package:flappy_bird/game/widgets/pause_button.dart';
import 'package:flappy_bird/core/services/high_score_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flappy_bird/core/ad_helper.dart';
import 'background.dart';
import 'bird.dart';
import 'ground.dart';
import 'pipe.dart';
import 'pipe_manager.dart';
import 'score.dart';
import '../core/constants.dart';

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Bird bird;
  late Background background;
  late Ground ground;
  late PipeManager pipe;
  late Score scoreComponent;

  double speedMultiplier = 1.0;
  static const double maxSpeedMultiplier = 4.5; // Prevents too-fast pipes

  final ValueNotifier<BannerAd?> bannerNotifier = ValueNotifier(null);
  InterstitialAd? interstitialAd;
  bool _isInterstitialAdReady = false;
  bool isGameOver = false;
  int score = 0;

  @override
  Future<void> onLoad() async {
    addAll([
      background = Background(),
      pipe = PipeManager(),
      ground = Ground(),
      scoreComponent = Score(),
      bird = Bird(),
    ]);

    overlays.addEntry('PauseMenu', (_, game) => PauseMenu(game: this));
    overlays.addEntry('pause_button', (_, game) => PauseButton(game: this));
    overlays.add('pause_button');

    // Load ads after slight delay
    Future.delayed(const Duration(milliseconds: 300), _loadBannerAd);
    loadInterstitialAd();
  }

  void _loadBannerAd() {
    final ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Game Banner Ad loaded');
          bannerNotifier.value = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Game Banner Ad failed: ${error.message}');
          ad.dispose();
          bannerNotifier.value = null;
        },
      ),
    );
    ad.load();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          _isInterstitialAdReady = true;
          debugPrint('✅ Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Failed to load interstitial ad: ${error.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  @override
  void onRemove() {
    bannerNotifier.value?.dispose();
    interstitialAd?.dispose();
    super.onRemove();
  }

  @override
  void onTap() => bird.jump();

  // 🧩 Game over logic

  int gameOverCounter = 0;

  void gameOver() {
    if (isGameOver) return;

    isGameOver = true;
    pauseEngine();

    gameOverCounter++;

    // ✅ Show interstitial only every 3rd game over
    final shouldShowAd = gameOverCounter % 3 == 0;

    if (shouldShowAd && _isInterstitialAdReady && interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          interstitialAd = null;
          loadInterstitialAd(); // preload next ad
          _showGameOverDialog();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          interstitialAd = null;
          loadInterstitialAd();
          _showGameOverDialog();
        },
      );
      interstitialAd!.show();
      _isInterstitialAdReady = false;
    } else {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    // Save high score
    HighScoreService.saveHighScore(score);

    showDialog(
      context: buildContext!,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: const Text('Game Over', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: Future.value(HighScoreService.getHighScore()),
              builder: (context, snapshot) {
                final highScore = snapshot.data ?? 0;
                return Text(
                  'High Score: $highScore',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          ElevatedButton(
            onPressed: () {
              bannerNotifier.value?.dispose();
              interstitialAd?.dispose();
              overlays.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const StartMenu()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Restart', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StartMenu()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Exit', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // 🌀 Reset the game
  void resetGame() {
    score = 0;
    isGameOver = false;
    speedMultiplier = 1.0;
    gameOverCounter = 0;

    bird
      ..position = Vector2(Constants.birdStartX, Constants.birdStartY)
      ..velocity = 0.0;

    children.whereType<Pipe>().forEach((pipe) => pipe.removeFromParent());
    pipe.pipeSpawnTimer = 0;
    scoreComponent.updateScore(0);

    pipe.updateSpeed(speedMultiplier);
    background.updateSpeed(speedMultiplier);
    ground.updateSpeed(speedMultiplier);

    resumeEngine();
  }

  // 📈 Score increase logic
  void incrementScore() {
    score += 1;
    scoreComponent.updateScore(score);

    speedMultiplier = 1 + (score / 50).clamp(0, 1.5);
    pipe.updateSpeed(speedMultiplier);
    background.updateSpeed(speedMultiplier);
    ground.updateSpeed(speedMultiplier);

    // Increase pipe difficulty every 10 points
    pipe.updateDifficulty(score);

    // You can keep your speedMultiplier logic if you like:
    if (score % 6 == 0 && speedMultiplier < maxSpeedMultiplier) {
      speedMultiplier += 1;
      pipe.updateSpeed(speedMultiplier);
      background.updateSpeed(speedMultiplier);
      ground.updateSpeed(speedMultiplier);
      debugPrint('🚀 Speed increased: x$speedMultiplier');
    }
  }

  void pauseGame() {
    if (!isGameOver && !overlays.isActive('PauseMenu')) {
      pauseEngine();
      overlays.add('PauseMenu');
      overlays.remove('pause_button');
    }
  }

  void resumeGame() {
    overlays.remove('PauseMenu');
    overlays.add('pause_button');
    resumeEngine();
  }

  ValueNotifier<bool> isPausedNotifier = ValueNotifier(false);

  void togglePause() => isPausedNotifier.value = !isPausedNotifier.value;
}
