import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flappy_bird/game/game.dart';
import 'package:flappy_bird/game/bird.dart';
import 'package:flutter/material.dart';

class Balloon extends PositionComponent with HasGameRef<FlappyBirdGame>, CollisionCallbacks {
  final double speed;

  Balloon({
    required Vector2 position,
    required this.speed,
  }) : super(
          position: position,
          size: Vector2(28, 38),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: 12, position: Vector2(2, 2)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move left in sync with the pipes and ground
    position.x -= speed * dt;
    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    final stringPaint = Paint()
      ..color = Colors.white38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw oval balloon shape
    canvas.drawOval(Rect.fromLTWH(0, 0, 24, 28), paint);

    // Draw small triangular knot at bottom
    final path = Path()
      ..moveTo(9, 28)
      ..lineTo(15, 28)
      ..lineTo(12, 31)
      ..close();
    canvas.drawPath(path, paint);

    // Draw hanging string line
    canvas.drawLine(const Offset(12, 31), const Offset(12, 38), stringPaint);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bird) {
      // Pop balloon! Add +3 bonus points
      gameRef.score += 3;
      gameRef.incrementBalloonsPopped();

      // Trigger a tiny camera shake on pop for extra visual weight
      gameRef.camera.viewfinder.add(
        MoveEffect.by(
          Vector2(3, 3),
          EffectController(duration: 0.05, alternate: true, repeatCount: 1),
        ),
      );
      removeFromParent();
    }
  }
}
