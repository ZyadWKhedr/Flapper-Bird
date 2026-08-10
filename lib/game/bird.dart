import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flappy_bird/core/constants.dart';
import 'package:flappy_bird/game/game.dart';
import 'package:flappy_bird/game/ground.dart';
import 'package:flappy_bird/game/components/power_up.dart';
import 'package:flappy_bird/game/components/trail_particle.dart';
import 'package:flappy_bird/game/components/weather_effect.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

import 'package:flappy_bird/core/services/high_score_service.dart';

class Bird extends SpriteComponent
    with HasGameRef<FlappyBirdGame>, CollisionCallbacks {

  bool isInvulnerable = false;
  bool isShrunk = false;
  double _powerUpTimer = 0.0;
  PowerUpType? activePowerUp;
  
  double _trailTimer = 0.0;
  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  Future<void> onLoad() async {
    await updateSkin();
    size = Vector2(Constants.birdWidth, Constants.birdHeight);
    position = Vector2(Constants.birdStartX, Constants.birdStartY);
    add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void onRemove() {
    _sfxPlayer.dispose();
    super.onRemove();
  }

  Future<void> updateSkin() async {
    final selectedSkin = HighScoreService.getSelectedBird();
    sprite = await gameRef.loadSprite(selectedSkin);
    size = Vector2(Constants.birdWidth, Constants.birdHeight);
    HighScoreService.clearTempBird();
  }

  void activatePowerUp(PowerUpType type) {
    activePowerUp = type;
    _powerUpTimer = 8.0; // Power-up lasts 8 seconds

    if (type == PowerUpType.shield) {
      isInvulnerable = true;
      isShrunk = false;
      size = Vector2(Constants.birdWidth, Constants.birdHeight);
    } else if (type == PowerUpType.shrink) {
      isShrunk = true;
      isInvulnerable = false;
      size = Vector2(Constants.birdWidth * 0.6, Constants.birdHeight * 0.6);
    }
  }

  late double velocity = Constants.velocity;

  void jump() {
    velocity = Constants.jumpStrength;
    if (HighScoreService.isMusicEnabled()) {
      _sfxPlayer.play(AssetSource('audio/flapping.mp3'), mode: PlayerMode.lowLatency);
    }
  }

  @override
  void update(double dt) {
    // Freeze bird position and physics instantly when game over is triggered
    if (gameRef.isGameOver) {
      velocity = 0;
      return;
    }

    // Decrement power-up timer
    if (_powerUpTimer > 0) {
      _powerUpTimer -= dt;
      if (_powerUpTimer <= 0) {
        // Reset power-up properties
        isInvulnerable = false;
        isShrunk = false;
        activePowerUp = null;
        size = Vector2(Constants.birdWidth, Constants.birdHeight);
      }
    }

    // 🌧️ / ❄️ Adjust gravity based on weather (rain pulls bird down, snow lifts it)
    double gravityModifier = 1.0;
    if (gameRef.weatherManager.type == WeatherType.rain) {
      gravityModifier = 1.15;
    } else if (gameRef.weatherManager.type == WeatherType.snow) {
      gravityModifier = 0.82;
    }

    velocity += Constants.gravity * gravityModifier * dt;
    position.y += velocity * dt;

    // ⛔ Clamp bird vertical position to prevent falling out of the ground or ceiling limits
    final maxBirdY = gameRef.size.y - Constants.groundHeight - size.y;
    if (position.y > maxBirdY) {
      position.y = maxBirdY;
      velocity = 0;
    }
    if (position.y < 0) {
      position.y = 0;
      velocity = 0;
    }

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw visual feedback for shield
    if (isInvulnerable) {
      final shieldPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.85,
        shieldPaint,
      );
    }
    
    // Draw visual indicator for shrink (a purple glow)
    if (isShrunk) {
      final shrinkPaint = Paint()
        ..color = Colors.purpleAccent.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.8,
        shrinkPaint,
      );
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Ground) gameRef.gameOver();
  }
}
