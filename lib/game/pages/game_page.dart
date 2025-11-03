import 'package:flame/game.dart';
import 'package:flappy_bird/game/game.dart';
import 'package:flappy_bird/game/menus/pause_menu.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  }

  @override
  void dispose() {
    game.bannerNotifier.value?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'PauseMenu': (context, _) => PauseMenu(game: game),
            },
          ),

          // ✅ Only show banner when paused
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
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: AdHelper.isTestMode
                        ? Border.all(color: Colors.red)
                        : null,
                  ),
                  child: ValueListenableBuilder<BannerAd?>(
                    valueListenable: game.bannerNotifier,
                    builder: (context, ad, _) {
                      if (ad == null) {
                        return const Center(
                          child: Text(
                            'Loading Ad...',
                            style: TextStyle(color: Colors.grey),
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
