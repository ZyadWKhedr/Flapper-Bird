import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flappy_bird/game/bird.dart';
import 'package:flappy_bird/core/constants.dart';
import 'package:flappy_bird/game/game.dart';

class Ground extends SpriteComponent
    with HasGameRef<FlappyBirdGame>, CollisionCallbacks {
  Ground()
    : super(position: Vector2(Constants.groundStartX, Constants.groundStartY));

  double baseSpeed = Constants.groundScrollingSpeed;
  double currentSpeed = Constants.groundScrollingSpeed;

  @override
  Future<void> onLoad() async {
    // Load sprite from the real game instance
    sprite = await gameRef.loadSprite('ground.png');

    // Set initial size based on the game screen width
    size = Vector2(gameRef.size.x * 2, Constants.groundHeight);

    // Position at the bottom of the screen
    position.y = gameRef.size.y - Constants.groundHeight;

    add(RectangleHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move ground to the left
    position.x -= Constants.groundScrollingSpeed * dt;

    // Loop ground for infinite scroll
    if (position.x <= -gameRef.size.x) {
      position.x = 0;
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    // Adjust ground position and size when screen changes
    size = Vector2(canvasSize.x * 2, Constants.groundHeight);
    position.y = canvasSize.y - Constants.groundHeight;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Bird) gameRef.gameOver();
  }

  void updateSpeed(double multiplier) {
    currentSpeed = baseSpeed * multiplier;
  }
}
