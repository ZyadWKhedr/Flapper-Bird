import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flappy_bird/game/game.dart';
import 'package:flappy_bird/game/bird.dart';
import 'package:flutter/material.dart';

enum PowerUpType { shield, shrink }

class PowerUp extends PositionComponent with HasGameRef<FlappyBirdGame>, CollisionCallbacks {
  final PowerUpType type;
  final double speed;
  double _bounceTime = 0.0;
  late final double _baseY;

  PowerUp({
    required this.type,
    required this.speed,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(32, 32),
          anchor: Anchor.center,
        ) {
    _baseY = position.y;
  }

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Glowing background bubble
    final bubblePaint = Paint()
      ..color = type == PowerUpType.shield 
          ? Colors.cyan.withOpacity(0.4) 
          : Colors.purpleAccent.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = type == PowerUpType.shield ? Colors.cyanAccent : Colors.purpleAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Glowing inner aura
    final glowPaint = Paint()
      ..color = type == PowerUpType.shield ? Colors.cyanAccent.withOpacity(0.2) : Colors.purpleAccent.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2 + 3, glowPaint);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, bubblePaint);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, borderPaint);

    // Inner icon details
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    if (type == PowerUpType.shield) {
      // Shield Shape
      final path = Path()
        ..moveTo(size.x * 0.35, size.y * 0.35)
        ..lineTo(size.x * 0.65, size.y * 0.35)
        ..lineTo(size.x * 0.65, size.y * 0.55)
        ..quadraticBezierTo(size.x * 0.65, size.y * 0.7, size.x * 0.5, size.y * 0.8)
        ..quadraticBezierTo(size.x * 0.35, size.y * 0.7, size.x * 0.35, size.y * 0.55)
        ..close();
      canvas.drawPath(path, iconPaint);
    } else {
      // Shrink Potion Bottle Shape
      final path = Path()
        ..moveTo(size.x * 0.45, size.y * 0.25)
        ..lineTo(size.x * 0.55, size.y * 0.25)
        ..lineTo(size.x * 0.55, size.y * 0.38)
        ..lineTo(size.x * 0.65, size.y * 0.48)
        ..lineTo(size.x * 0.65, size.y * 0.75)
        ..lineTo(size.x * 0.35, size.y * 0.75)
        ..lineTo(size.x * 0.35, size.y * 0.48)
        ..lineTo(size.x * 0.45, size.y * 0.38)
        ..close();
      canvas.drawPath(path, iconPaint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move left in sync with ground and obstacles
    position.x -= speed * dt;

    // Hover floating effect
    _bounceTime += dt * 4;
    position.y = _baseY + sin(_bounceTime) * 6;

    if (position.x < -size.x) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bird) {
      other.activatePowerUp(type);
      removeFromParent();
    }
  }
}
