import 'dart:math';
import 'package:flame/components.dart';
import 'package:flappy_bird/game/game.dart';
import 'package:flutter/material.dart';
import 'package:flappy_bird/core/services/high_score_service.dart';

class RainbowTrail extends PositionComponent with HasGameRef<FlappyBirdGame> {
  final List<Vector2> _positions = [];
  double _timer = 0.0;

  RainbowTrail() : super(priority: 85); // Render behind the bird

  @override
  void update(double dt) {
    super.update(dt);

    final selectedTrail = HighScoreService.getSelectedTrail();
    if (selectedTrail != 'none') {
      // Shift older positions to the left in sync with game scrolling speed
      final scrollOffset = gameRef.pipe.currentSpeed * dt;
      for (var pos in _positions) {
        pos.x -= scrollOffset;
      }

      // Cleanup points that have drifted off-screen
      _positions.removeWhere((pos) => pos.x < -50);

      if (!gameRef.isGameOver) {
        _timer += dt;
        if (_timer > 0.02) {
          _timer = 0.0;
          // Spawn trail point at the back edge of the bird
          final birdBack = Vector2(
            gameRef.bird.position.x + 4, 
            gameRef.bird.position.y + gameRef.bird.size.y / 2,
          );
          _positions.insert(0, birdBack.clone());

          // Cap max trail length to make it long but performant
          if (_positions.length > 55) {
            _positions.removeLast();
          }
        }
      }
    } else {
      _positions.clear();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_positions.length < 2) return;

    final selectedTrail = HighScoreService.getSelectedTrail();
    if (selectedTrail == 'rainbow') {
      _renderRainbow(canvas);
    } else if (selectedTrail == 'fire') {
      _renderFire(canvas);
    } else if (selectedTrail == 'sparkle') {
      _renderSparkle(canvas);
    }
  }

  void _renderRainbow(Canvas canvas) {
    final colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.yellowAccent,
      Colors.greenAccent,
      Colors.cyanAccent,
      Colors.purpleAccent,
    ];

    const double bandHeight = 3.5;

    // Draw the stacked colors of the rainbow track
    for (int c = 0; c < colors.length; c++) {
      final double yOffset = (c - colors.length / 2) * bandHeight;

      for (int i = 0; i < _positions.length - 1; i++) {
        final double factor = 1.0 - (i / _positions.length);
        final opacity = factor.clamp(0.0, 1.0);

        final paint = Paint()
          ..color = colors[c].withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = bandHeight
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(_positions[i].x, _positions[i].y + yOffset),
          Offset(_positions[i + 1].x, _positions[i + 1].y + yOffset),
          paint,
        );
      }
    }
  }

  void _renderFire(Canvas canvas) {
    final random = Random();
    for (int i = 0; i < _positions.length; i++) {
      final double factor = 1.0 - (i / _positions.length);
      final opacity = factor.clamp(0.0, 1.0);

      // Core fire
      final corePaint = Paint()
        ..color = Colors.orangeAccent.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(_positions[i].x, _positions[i].y), 7.0 * factor, corePaint);

      // Outer flame aura
      final outerPaint = Paint()
        ..color = Colors.redAccent.withOpacity(opacity * 0.45)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(_positions[i].x - 5.0, _positions[i].y + (random.nextDouble() * 6.0 - 3.0)),
        11.0 * factor,
        outerPaint,
      );

      // Sparkles
      if (i % 3 == 0) {
        final sparkPaint = Paint()
          ..color = Colors.yellowAccent.withOpacity(opacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(_positions[i].x - 8.0, _positions[i].y + (random.nextDouble() * 8.0 - 4.0)),
          2.5 * factor,
          sparkPaint,
        );
      }
    }
  }

  void _renderSparkle(Canvas canvas) {
    for (int i = 0; i < _positions.length; i++) {
      if (i % 2 != 0) continue; // Sparkles spaced out
      final double factor = 1.0 - (i / _positions.length);
      final opacity = factor.clamp(0.0, 1.0);

      final paint = Paint()
        ..color = Colors.amberAccent.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      _drawStar(canvas, Offset(_positions[i].x, _positions[i].y), 8.0 * factor, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size) // Top point
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy) // to Right
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size) // to Bottom
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy) // to Left
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size); // back to Top
    canvas.drawPath(path, paint);
  }
}
