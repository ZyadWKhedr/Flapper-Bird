import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flappy_bird/game/bird.dart';
import 'package:flappy_bird/game/game.dart';

class Pipe extends SpriteComponent
    with HasGameRef<FlappyBirdGame>, CollisionCallbacks {
  final bool isTopPipe;
  final double pipeHeight;
  final double pipeWidth;
  final double posY;
  double speed;

  bool passed = false;

  // Oscillation properties
  double baseY = 0;
  double time = 0;
  double oscillationAmplitude = 0;
  double oscillationSpeed = 0;

  final Random _random = Random();

  Pipe({
    required this.isTopPipe,
    required this.pipeHeight,
    required this.pipeWidth,
    required this.posY,
    required this.speed,
  }) : super();

  @override
  FutureOr<void> onLoad() async {
    position = Vector2(gameRef.size.x, posY);
    size = Vector2(pipeWidth, pipeHeight);

    final image = await gameRef.images.load(
      isTopPipe ? 'top_pipe.png' : 'bottom_pipe.png',
    );
    sprite = Sprite(image);

    add(RectangleHitbox());
    baseY = posY;

    // Randomly oscillate some pipes (not all)
    if (_random.nextBool()) {
      oscillationAmplitude = 10 + _random.nextDouble() * 20;
      oscillationSpeed = 1.5 + _random.nextDouble() * 1.5;
    }

    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bird) {
      gameRef.gameOver();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    // Dynamic difficulty — based on player score
    final score = gameRef.score;
    final difficultyMultiplier = (1 + score / 50).clamp(1.0, 2.5);
    final adjustedSpeed = speed * difficultyMultiplier;

    // Move left
    position.x -= adjustedSpeed * dt;

    // Optional: small vertical oscillation for moving pipes
    if (oscillationAmplitude > 0) {
      y = baseY + sin(time * oscillationSpeed) * oscillationAmplitude;
    }

    // ✅ Increment score when bird passes
    if (!isTopPipe &&
        !passed &&
        position.x + size.x < gameRef.bird.position.x) {
      passed = true;
      gameRef.incrementScore();
    }

    // Remove when off-screen
    if (position.x <= -size.x) {
      removeFromParent();
    }
  }
}
