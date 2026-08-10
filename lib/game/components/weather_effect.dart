import 'dart:math';
import 'package:flame/components.dart';
import 'package:flappy_bird/game/game.dart';
import 'package:flutter/material.dart';

enum WeatherType { clear, rain, snow }

class WeatherManager extends PositionComponent with HasGameRef<FlappyBirdGame> {
  WeatherType type = WeatherType.clear;
  final Random random = Random();
  final List<WeatherParticle> particles = [];
  double spawnTimer = 0.0;

  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    randomizeWeather();
    return super.onLoad();
  }

  void randomizeWeather() {
    final r = random.nextInt(3);
    type = r == 0 ? WeatherType.clear : (r == 1 ? WeatherType.rain : WeatherType.snow);
    debugPrint('⛈️ Current weather set to: $type');
  }

  @override
  void update(double dt) {
    super.update(dt);
    size = gameRef.size;
    if (type == WeatherType.clear) return;

    // Spawn new weather particles
    spawnTimer += dt;
    double interval = type == WeatherType.rain ? 0.015 : 0.05;
    if (spawnTimer > interval) {
      spawnTimer = 0.0;
      particles.add(
        WeatherParticle(
          type: type,
          position: Vector2(random.nextDouble() * size.x, -10),
          speed: type == WeatherType.rain 
              ? 500 + random.nextDouble() * 200 
              : 120 + random.nextDouble() * 50,
          angle: type == WeatherType.rain ? 1.3 : 1.57 + (random.nextDouble() * 0.3 - 0.15),
        ),
      );
    }

    // Update existing particles
    for (int i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.update(dt);
      if (p.position.y > size.y || p.position.x < -10 || p.position.x > size.x + 10) {
        particles.removeAt(i);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (type == WeatherType.clear) return;

    final paint = Paint()
      ..color = type == WeatherType.rain 
          ? Colors.blue.withOpacity(0.35) 
          : Colors.white.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    for (final p in particles) {
      if (type == WeatherType.rain) {
        // Draw diagonal rain drop streak
        canvas.drawLine(
          p.position.toOffset(),
          Offset(p.position.x - 4, p.position.y + 12),
          paint..strokeWidth = 1.2,
        );
      } else {
        // Draw drifting snowflake circle
        canvas.drawCircle(p.position.toOffset(), 2.0, paint);
      }
    }
  }
}

class WeatherParticle {
  final WeatherType type;
  final Vector2 position;
  final double speed;
  final double angle;

  WeatherParticle({
    required this.type,
    required this.position,
    required this.speed,
    required this.angle,
  });

  void update(double dt) {
    position.x += cos(angle) * speed * dt;
    position.y += sin(angle) * speed * dt;
  }
}
