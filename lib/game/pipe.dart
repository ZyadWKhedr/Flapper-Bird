import 'dart:async';
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
  final double speed;

  bool passed = false; // ✅ track if bird passed this pipe

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

    // Move pipe left
    position.x -= speed * dt;

    // Increment score when bird passes bottom pipe
    if (!isTopPipe &&
        !passed &&
        position.x + size.x < gameRef.bird.position.x) {
      passed = true;
      gameRef.incrementScore();
    }

    // Remove off-screen pipes
    if (position.x <= -size.x) {
      removeFromParent();
    }
  }
}
