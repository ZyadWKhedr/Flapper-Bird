import 'package:audioplayers/audioplayers.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flappy_bird/game/menus/game_over_menu.dart';
import 'package:flutter/material.dart';
import 'package:flame/effects.dart';
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
import 'components/power_up.dart';
import 'components/weather_effect.dart';
import 'components/rainbow_trail.dart';
import 'components/balloon.dart';
import 'menus/pause_menu.dart';
import 'menus/start_menu.dart';

class FlappyBirdGame extends FlameGame with TapDetector, HasCollisionDetection {
  late final Background background;
  late final Bird bird;
  late final PipeManager pipe;
  late final Ground ground;
  late final WeatherManager weatherManager;
  late final RainbowTrail rainbowTrail;

  double speedMultiplier = 1.0;
  static const double maxSpeedMultiplier = 8.5;

  final ValueNotifier<BannerAd?> bannerNotifier = ValueNotifier(null);
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> balloonsNotifier = ValueNotifier(0);
  InterstitialAd? interstitialAd;
  bool _isInterstitialReady = false;
  bool isGameOver = false;
  int score = 0;
  int balloonsPopped = 0;
  int _gameOverCounter = 0;
  // 🧭 Pause notifier — used by UI (e.g. GamePage) to detect pause state
  final ValueNotifier<bool> isPausedNotifier = ValueNotifier(false);

  @override
  Future<void> onLoad() async {
    addAll([
      background = Background(),
      pipe = PipeManager(),
      ground = Ground(),
      bird = Bird(),
      weatherManager = WeatherManager()..priority = 90, // render on top of background but below text
      rainbowTrail = RainbowTrail(),
    ]);

    overlays.addEntry('PauseMenu', (_, game) => PauseMenu(game: this));
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
    if (isGameOver) return;
    isGameOver = true;

    if (HighScoreService.isMusicEnabled()) {
      AudioPlayer().play(AssetSource('audio/audio_hit.wav'), mode: PlayerMode.lowLatency);
      Future.delayed(const Duration(milliseconds: 160), () {
        AudioPlayer().play(AssetSource('audio/audio_die.wav'), mode: PlayerMode.lowLatency);
      });
    }

    // 📳 Shake camera viewport using modern Flame effects on viewfinder
    camera.viewfinder.add(
      MoveEffect.by(
        Vector2(10, 10),
        EffectController(
          duration: 0.05,
          alternate: true,
          repeatCount: 3,
        ),
      ),
    );

    // ⛔ Freeze all moving objects instantly so the screen doesn't slide during shake
    speedMultiplier = 0.0;
    pipe.updateSpeed(0);
    ground.updateSpeed(0);
    background.updateSpeed(0);

    HighScoreService.saveHighScore(score);
    HighScoreService.addBalloons(balloonsPopped);
    overlays.remove('PauseMenu');
    _gameOverCounter++;
    debugPrint('💀 Game over count: $_gameOverCounter');

    // 🎯 Present the game over options instantly for maximum snappiness
    if ((_gameOverCounter % 3) == 0 &&
        _isInterstitialReady &&
        interstitialAd != null) {
      debugPrint('🎬 Showing interstitial after 3rd game over');
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd(); // Preload the next ad
          overlays.add('GameOverMenu'); // Show Game Over screen after ad closes
          pauseEngine();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          overlays.add('GameOverMenu');
          pauseEngine();
        },
      );
      interstitialAd!.show();
    } else {
      overlays.add('GameOverMenu');
      // Delay pausing the engine slightly so the camera shake effect runs to completion
      Future.delayed(const Duration(milliseconds: 300), () {
        if (isGameOver) {
          pauseEngine();
        }
      });
    }
  }

  // -------------------------- RESET ----------------------------

  void resetGame() {
    score = 0;
    balloonsPopped = 0;
    isGameOver = false;
    speedMultiplier = 1.0;

    // Revert to permanent skin selection after 1 game
    HighScoreService.clearTempBird();

    bird
      ..position = Vector2(Constants.birdStartX, Constants.birdStartY)
      ..velocity = 0
      ..isInvulnerable = false
      ..isShrunk = false
      ..activePowerUp = null
      ..updateSkin();

    children.whereType<Pipe>().forEach((pipe) => pipe.removeFromParent());
    children.whereType<PowerUp>().forEach((p) => p.removeFromParent());
    children.whereType<Balloon>().forEach((b) => b.removeFromParent());
    
    pipe
      ..pipeSpawnTimer = 0
      ..resetSpawnTracker()
      ..updateSpeed(speedMultiplier);

    weatherManager.randomizeWeather();

    scoreNotifier.value = 0;
    balloonsNotifier.value = 0;
    background.updateBackgroundForScore(0);
    background.updateSpeed(speedMultiplier * 0.4); // 0.4x speed for parallax
    ground.updateSpeed(speedMultiplier);

    resumeEngine();
  }

  // -------------------------- SCORE & DIFFICULTY ----------------------------

  void incrementBalloonsPopped() {
    balloonsPopped += 1;
    balloonsNotifier.value = balloonsPopped;
  }

  void incrementScore() {
    score += 1;
    scoreNotifier.value = score;

    // Shift weather pattern dynamically every 15 points
    if (score > 0 && score % 15 == 0) {
      weatherManager.randomizeWeather();
    }

    // Increase speed gradually after 5 scores
    double effectiveScore = (score - 5).clamp(0, score).toDouble();
    speedMultiplier = 1.0 + (effectiveScore / 80).clamp(0, 2.0);

    // Apply to all moving elements (with background moving slower for parallax)
    pipe.updateSpeed(speedMultiplier);
    background.updateSpeed(speedMultiplier * 0.4); // 0.4x speed for parallax
    background.updateBackgroundForScore(score); // dynamically switch backgrounds
    ground.updateSpeed(speedMultiplier);

    // Update difficulty parameters only (gap, not speed)
    pipe.updateDifficulty(score);
  }

  // -------------------------- PAUSE / RESUME ----------------------------

  void pauseGame() {
    if (!isGameOver && !overlays.isActive('PauseMenu')) {
      pauseEngine();
      overlays.add('PauseMenu');
      isPausedNotifier.value = true; // ✅ tell UI game is paused
    }
  }

  void resumeGame() {
    overlays.remove('PauseMenu');
    resumeEngine();
    isPausedNotifier.value = false; // ✅ tell UI game resumed
  }
}
