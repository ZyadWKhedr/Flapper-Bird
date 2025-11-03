import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flappy_bird/core/ad_helper.dart';
import 'package:flappy_bird/core/services/high_score_service.dart';
import 'package:flappy_bird/game/menus/start_menu.dart';
import 'package:flappy_bird/game/game.dart';

class GameOverMenu extends StatefulWidget {
  final FlappyBirdGame game;
  final int score;

  const GameOverMenu({super.key, required this.game, required this.score});

  @override
  State<GameOverMenu> createState() => _GameOverMenuState();
}

class _GameOverMenuState extends State<GameOverMenu> {
  BannerAd? _gameOverBanner;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  // -------------------- Banner Ad --------------------
  void _loadBanner() {
    final ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _gameOverBanner = ad as BannerAd);
          debugPrint('✅ Game Over banner loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Game Over banner failed: ${error.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _gameOverBanner?.dispose();
    super.dispose();
  }

  // -------------------- Game Controls --------------------
  void _playAgain() {
    widget.game.overlays.remove('GameOverMenu');
    widget.game.resetGame();
  }

  void _exitToMenu() {
    widget.game.overlays.remove('GameOverMenu');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const StartMenu()),
    );
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    final highScore = HighScoreService.getHighScore();

    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Game Over',
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Score: ${widget.score}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  'High Score: $highScore',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _playAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _exitToMenu,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Exit', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),

        // 🟩 Banner at bottom of page
        if (_gameOverBanner != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: _gameOverBanner!.size.width.toDouble(),
                height: _gameOverBanner!.size.height.toDouble(),
                child: AdWidget(ad: _gameOverBanner!),
              ),
            ),
          ),
      ],
    );
  }
}
