import 'dart:math';
import 'package:flame/components.dart';
import 'package:flappy_bird/core/constants.dart';
import 'package:flappy_bird/game/game.dart';

class Background extends Component with HasGameRef<FlappyBirdGame> {
  late final SpriteComponent bg1;
  late final SpriteComponent bg2;
  
  // Transition overlay backgrounds
  late final SpriteComponent fadeBg1;
  late final SpriteComponent fadeBg2;

  bool _isLoaded = false;
  bool _isTransitioning = false;
  double _transitionProgress = 0.0;
  static const double _transitionDuration = 1.2; // Smooth 1.2 seconds crossfade

  late final Sprite pinkSprite;
  late final Sprite purpleSprite;
  late final Sprite blueCloudsSprite;
  late final Sprite cyanCloudsSprite;
  late final Sprite defaultSprite;
  late final Sprite citySprite;

  final List<String> _bgTypes = [
    'pink',
    'purple',
    'blue_clouds',
    'cyan_clouds',
    'default',
    'city',
  ];
  late final Map<String, Sprite> _bgSprites;

  String _currentBg = '';
  String get currentBg => _currentBg;
  final Random _random = Random();

  double baseSpeed = Constants.backgroundScrollingSpeed;
  double currentSpeed = Constants.backgroundScrollingSpeed;

  void updateSpeed(double multiplier) {
    currentSpeed = baseSpeed * multiplier;
  }

  @override
  Future<void> onLoad() async {
    pinkSprite = await gameRef.loadSprite(AppImages.backgroundPink);
    purpleSprite = await gameRef.loadSprite(AppImages.backgroundPurple);
    blueCloudsSprite = await gameRef.loadSprite(AppImages.backgroundBlueClouds);
    cyanCloudsSprite = await gameRef.loadSprite(AppImages.backgroundCyanClouds);
    defaultSprite = await gameRef.loadSprite(AppImages.backgroundDefault);
    citySprite = await gameRef.loadSprite(AppImages.backgroundCity);

    _bgSprites = {
      'pink': pinkSprite,
      'purple': purpleSprite,
      'blue_clouds': blueCloudsSprite,
      'cyan_clouds': cyanCloudsSprite,
      'default': defaultSprite,
      'city': citySprite,
    };

    final screenSize = gameRef.size;
    final initialBg = _bgTypes[_random.nextInt(_bgTypes.length)];
    final sprite = _bgSprites[initialBg]!;

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

    fadeBg1 = SpriteComponent(
      sprite: sprite,
      size: screenSize,
      position: Vector2.zero(),
    )..opacity = 0.0;

    fadeBg2 = SpriteComponent(
      sprite: sprite,
      size: screenSize,
      position: Vector2(screenSize.x, 0),
    )..opacity = 0.0;

    await addAll([bg1, bg2, fadeBg1, fadeBg2]);
    _isLoaded = true;
    _currentBg = initialBg;
  }

  void updateBackgroundForScore(int score) {
    if (!_isLoaded || _isTransitioning) return;

    // Change background randomly every 10 scores
    if (score > 0 && score % 10 == 0) {
      final options = _bgTypes.where((type) => type != _currentBg).toList();
      final newBg = options[_random.nextInt(options.length)];
      final sprite = _bgSprites[newBg]!;

      // Setup fade overlay
      fadeBg1.sprite = sprite;
      fadeBg2.sprite = sprite;
      fadeBg1.opacity = 0.0;
      fadeBg2.opacity = 0.0;
      
      _currentBg = newBg;
      _isTransitioning = true;
      _transitionProgress = 0.0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isLoaded) return;

    // Scroll base backgrounds
    for (final bg in [bg1, bg2]) {
      bg.position.x -= currentSpeed * dt;
      if (bg.position.x <= -gameRef.size.x) {
        bg.position.x += gameRef.size.x * 2;
      }
    }

    // Scroll transition backgrounds in sync
    for (final bg in [fadeBg1, fadeBg2]) {
      bg.position.x -= currentSpeed * dt;
      if (bg.position.x <= -gameRef.size.x) {
        bg.position.x += gameRef.size.x * 2;
      }
    }

    // Animate crossfade transition
    if (_isTransitioning) {
      _transitionProgress += dt;
      double progress = (_transitionProgress / _transitionDuration).clamp(0.0, 1.0);
      
      fadeBg1.opacity = progress;
      fadeBg2.opacity = progress;
      bg1.opacity = 1.0 - progress;
      bg2.opacity = 1.0 - progress;

      if (progress >= 1.0) {
        // Finalize: make the transition sprite the base sprite
        bg1.sprite = fadeBg1.sprite;
        bg2.sprite = fadeBg2.sprite;
        
        bg1.opacity = 1.0;
        bg2.opacity = 1.0;
        fadeBg1.opacity = 0.0;
        fadeBg2.opacity = 0.0;
        
        _isTransitioning = false;
      }
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (!_isLoaded) return;

    bg1.size = canvasSize;
    bg2.size = canvasSize;
    fadeBg1.size = canvasSize;
    fadeBg2.size = canvasSize;

    bg1.position = Vector2.zero();
    bg2.position = Vector2(canvasSize.x, 0);
    fadeBg1.position = Vector2.zero();
    fadeBg2.position = Vector2(canvasSize.x, 0);
  }
}
