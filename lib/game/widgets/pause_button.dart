import 'package:flutter/material.dart';
import 'package:flappy_bird/game/game.dart';

class PauseButton extends StatelessWidget {
  final FlappyBirdGame game;

  const PauseButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 30,
      child: IconButton(
        icon: const Icon(Icons.pause_circle, color: Colors.white, size: 40),
        onPressed: () {
          game.pauseGame();
        },
      ),
    );
  }
}
