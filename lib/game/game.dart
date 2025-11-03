import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flappy_bird/game/menus/game_over_menu.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

import '../core/ad_helper.dart';
import '../core/constants.dart';
import '../core/services/high_score_service.dart';

import 'background.dart';
import 'bird.dart';
import 'ground.dart';
import 'pipe.dart';
import 'pipe_manager.dart';
import 'score.dart';
import 'menus/pause_menu.dart';
import 'menus/start_menu.dart';
import 'widgets/pause_button.dart';

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Bird bird;
  late Background background;
  late Ground ground;
  late PipeManager pipe;
  late Score scoreComponent;

  double speedMultiplier = 2.0;
  static const double maxSpeedMultiplier = 8.5;

  final ValueNotifier<BannerAd?> bannerNotifier = ValueNotifier(null);
  InterstitialAd? interstitialAd;
  bool _isInterstitialReady = false;
  bool isGameOver = false;
  int score = 0;
  int _gameOverCounter = 0;
  // 🧭 Pause notifier — used by UI (e.g. GamePage) to detect pause state
  final ValueNotifier<bool> isPausedNotifier = ValueNotifier(false);

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
    overlays.addEntry(
      'GameOverMenu',
      (_, game) => GameOverMenu(game: this, score: score),
    );
    Future.delayed(const Duration(milliseconds: 300), _loadBannerAd);
    _loadInterstitialAd();
  }

  // -------------------------- ADS ----------------------------

  void _loadBannerAd() {
    final ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Game banner loaded');
          bannerNotifier.value = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner failed: ${error.message}');
          ad.dispose();
          bannerNotifier.value = null;
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          _isInterstitialReady = true;
          debugPrint('✅ Interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Interstitial failed: ${error.message}');
          _isInterstitialReady = false;
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

  // -------------------------- INPUT ----------------------------

  @override
  void onTap() => bird.jump();

  // -------------------------- GAME OVER ----------------------------

  void gameOver() {
    pauseEngine();
    HighScoreService.saveHighScore(score);

    overlays.remove('PauseMenu');

    _gameOverCounter++;
    debugPrint('💀 Game over count: $_gameOverCounter');

    // 🎯 Show an interstitial ad every 3rd game over only
    if ((_gameOverCounter % 3) == 0 &&
        _isInterstitialReady &&
        interstitialAd != null) {
      debugPrint('🎬 Showing interstitial after 3rd game over');
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd(); // Preload the next ad
          overlays.add('GameOverMenu'); // Show Game Over screen after ad closes
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          overlays.add('GameOverMenu');
        },
      );
      interstitialAd!.show();
    } else {
      overlays.add('GameOverMenu');
    }
  }

  // -------------------------- RESET ----------------------------

  void resetGame() {
    score = 0;
    isGameOver = false;
    speedMultiplier = 1.0;

    bird
      ..position = Vector2(Constants.birdStartX, Constants.birdStartY)
      ..velocity = 0;

    children.whereType<Pipe>().forEach((pipe) => pipe.removeFromParent());
    pipe
      ..pipeSpawnTimer = 0
      ..updateSpeed(speedMultiplier);

    scoreComponent.updateScore(0);
    background.updateSpeed(speedMultiplier);
    ground.updateSpeed(speedMultiplier);

    resumeEngine();
  }

  // -------------------------- SCORE & DIFFICULTY ----------------------------

  void incrementScore() {
    score += 1;
    scoreComponent.updateScore(score);

    // Smooth continuous scaling instead of jumps
    speedMultiplier = 1 + (score / 80).clamp(0, 2.0);

    // Apply to all moving elements
    pipe.updateSpeed(speedMultiplier);
    background.updateSpeed(speedMultiplier * 1.1); // slight boost for realism
    ground.updateSpeed(
      speedMultiplier * 1.25,
    ); // make ground scroll faster for intensity

    // Update difficulty parameters only (gap, not speed)
    pipe.updateDifficulty(score);
  }

  // -------------------------- PAUSE / RESUME ----------------------------

  void pauseGame() {
    if (!isGameOver && !overlays.isActive('PauseMenu')) {
      pauseEngine();
      overlays.add('PauseMenu');
      overlays.remove('pause_button');
      isPausedNotifier.value = true; // ✅ tell UI game is paused
    }
  }

  void resumeGame() {
    overlays.remove('PauseMenu');
    overlays.add('pause_button');
    resumeEngine();
    isPausedNotifier.value = false; // ✅ tell UI game resumed
  }
}
