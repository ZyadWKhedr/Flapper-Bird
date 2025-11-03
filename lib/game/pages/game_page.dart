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
