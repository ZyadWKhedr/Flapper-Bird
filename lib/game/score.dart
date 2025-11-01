import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flappy_bird/game/game.dart';

class Score extends TextComponent with HasGameRef<FlappyBirdGame> {
  Score()
    : super(
        text: '0',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontFamily: 'PixelFont',
            fontSize: 48,
            color: Colors.white,
          ),
        ),
        anchor: Anchor.topCenter,
      );

  @override
  Future<void> onLoad() async {
    position = Vector2(gameRef.size.x / 2, 50);
    return super.onLoad();
  }

  void updateScore(int score) {
    text = score.toString();
  }
}
