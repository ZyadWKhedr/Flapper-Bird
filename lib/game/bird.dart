import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flappy_bird/core/constants.dart';
import 'package:flappy_bird/game/game.dart';
import 'package:flappy_bird/game/ground.dart';

class Bird extends SpriteComponent with CollisionCallbacks {
  final Game game = FlappyBirdGame();

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('bird.png');
    size = Vector2(Constants.birdWidth, Constants.birdHeight);
    position = Vector2(Constants.birdStartX, Constants.birdStartY);
    add(CircleHitbox());
    return super.onLoad();
  }

  late double velocity = Constants.velocity;

  void jump() {
    velocity = Constants.jumpStrength;
  }

  @override
  void update(double dt) {
    velocity += Constants.gravity * dt;
    position.y += velocity * dt;
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Ground) (parent as FlappyBirdGame).gameOver();
  }
}
