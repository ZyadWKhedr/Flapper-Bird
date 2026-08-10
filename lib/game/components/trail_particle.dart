import 'dart:math';
import 'package:flame/components.dart';
import 'package:flappy_bird/game/game.dart';
import 'package:flutter/material.dart';

class TrailParticle extends PositionComponent with HasGameRef<FlappyBirdGame> {
  final Color color;
  final double maxLife = 0.5;
  double life = 0.5;
  late final Vector2 velocity;

  TrailParticle({
    required Vector2 position,
    required this.color,
  }) : super(
          position: position,
          size: Vector2(6, 6),
          anchor: Anchor.center,
        ) {
    final random = Random();
    velocity = Vector2(
      -60 - random.nextDouble() * 30, // Drift backwards
      random.nextDouble() * 20 - 10,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    position += velocity * dt;
    if (life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = color.withOpacity((life / maxLife).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    
    // Draw beautiful fading particle circle
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      (size.x / 2) * (life / maxLife),
      paint,
    );
  }
}
