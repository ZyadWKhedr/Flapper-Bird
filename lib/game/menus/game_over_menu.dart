import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flappy_bird/core/ad_helper.dart';
import 'package:flappy_bird/core/constants.dart';
import 'package:flappy_bird/core/services/high_score_service.dart';
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
  bool _copied = false;

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
          if (mounted) {
            setState(() => _gameOverBanner = ad as BannerAd);
            debugPrint('✅ Game Over banner loaded.');
          } else {
            ad.dispose();
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Game Over banner failed: ${error.message}');
          ad.dispose();
        },
      ),
    );
    ad.load();
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
    Navigator.of(context).pop();
  }

  void _shareScore() {
    final text = 'I just scored ${widget.score} in Flapper Bird! Can you beat me?';
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _copied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
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
            width: 290,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amberAccent.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppImages.flutterPath(AppImages.gameover),
                  height: 38,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18),
                Text(
                  'SCORE: ${widget.score}',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'BEST RECORD: $highScore',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Share Score Button (Full width above game actions)
                ElevatedButton.icon(
                  onPressed: _shareScore,
                  icon: Icon(_copied ? Icons.check_circle : Icons.share, size: 16, color: Colors.black),
                  label: Text(
                    _copied ? 'COPIED SNIPPET!' : 'SHARE SCORE',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Game Action Controls Row (Play Again and Exit side by side)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _playAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'PLAY',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _exitToMenu,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'EXIT',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
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
