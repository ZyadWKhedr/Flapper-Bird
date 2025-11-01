import 'package:flame/components.dart';
import 'package:flappy_bird/core/constants.dart';
import 'package:flappy_bird/game/game.dart';

class Background extends Component with HasGameRef<FlappyBirdGame> {
  late final SpriteComponent bg1;
  late final SpriteComponent bg2;
  bool _isLoaded = false;

  double baseSpeed = Constants.backgroundScrollingSpeed;
  double currentSpeed = Constants.backgroundScrollingSpeed;

  void updateSpeed(double multiplier) {
    currentSpeed = baseSpeed * multiplier;
  }

  @override
  Future<void> onLoad() async {
    final sprite = await gameRef.loadSprite('background.png');
    final screenSize = gameRef.size;

    bg1 = SpriteComponent(
      sprite: sprite,
      size: screenSize,
      position: Vector2.zero(),
    );

    bg2 = SpriteComponent(
      sprite: sprite,
      size: screenSize,
      position: Vector2(screenSize.x, 0),
    );

    await addAll([bg1, bg2]);
    _isLoaded = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isLoaded) return;

    for (final bg in [bg1, bg2]) {
      bg.position.x -= currentSpeed * dt;

      if (bg.position.x <= -gameRef.size.x) {
        bg.position.x += gameRef.size.x * 2;
      }
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (!_isLoaded) return;

    bg1.size = canvasSize;
    bg2.size = canvasSize;
    bg1.position = Vector2.zero();
    bg2.position = Vector2(canvasSize.x, 0);
  }
}
