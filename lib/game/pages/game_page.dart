import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flappy_bird/game/game.dart';
import 'package:flappy_bird/game/menus/pause_menu.dart';
import '../../core/ad_helper.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late FlappyBirdGame game;

  @override
  void initState() {
    super.initState();
    game = FlappyBirdGame();

    // Ensure ad loads when the game starts
    Future.delayed(const Duration(milliseconds: 300), () {
      game.bannerNotifier.value ??
          game.bannerNotifier.value?.load(); // just a safety call
    });
  }

  @override
  void dispose() {
    game.bannerNotifier.value?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          /// 🎮 Game itself
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'PauseMenu': (context, _) => PauseMenu(game: game),
            },
          ),

          /// 🏆 Premium Glassmorphic HUD overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Glassmorphic Score & Balloon Counter Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Score counter
                      const Icon(Icons.emoji_events_rounded, color: Colors.amberAccent, size: 24),
                      const SizedBox(width: 6),
                      ValueListenableBuilder<int>(
                        valueListenable: game.scoreNotifier,
                        builder: (context, score, _) {
                          return Text(
                            '$score',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 18),
                      // Balloon counter
                      const Text(
                        '🎈',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ValueListenableBuilder<int>(
                        valueListenable: game.balloonsNotifier,
                        builder: (context, balloons, _) {
                          return Text(
                            '$balloons',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Pause Action Button
                GestureDetector(
                  onTap: () {
                    game.pauseEngine();
                    game.isPausedNotifier.value = true;
                    game.overlays.add('PauseMenu');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🪧 Banner ad shown ONLY when paused
          ValueListenableBuilder<bool>(
            valueListenable: game.isPausedNotifier,
            builder: (context, isPaused, _) {
              if (!isPaused) return const SizedBox.shrink();

              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: AdSize.banner.width.toDouble(),
                  height: AdSize.banner.height.toDouble(),
                  color: Colors.transparent,
                  child: ValueListenableBuilder<BannerAd?>(
                    valueListenable: game.bannerNotifier,
                    builder: (context, ad, _) {
                      if (ad == null) {
                        return const SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              'Loading Ad...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        );
                      }
                      return AdWidget(ad: ad);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
