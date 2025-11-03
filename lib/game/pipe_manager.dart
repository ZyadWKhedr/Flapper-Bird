import 'dart:math';
import 'package:flame/components.dart';
import 'package:flappy_bird/core/constants.dart';
import 'package:flappy_bird/game/game.dart';
import 'package:flappy_bird/game/pipe.dart';

class PipeManager extends Component with HasGameRef<FlappyBirdGame> {
  double pipeSpawnTimer = 0;
  final Random random = Random();

  late double pipeSpawnInterval;
  double basePipeSpeed = Constants.pipeScrollingSpeed;
  double currentSpeed = Constants.pipeScrollingSpeed;

  // ✅ Difficulty parameters
  int difficultyLevel = 1;
  double minGapRatio = 0.25;
  double maxGapRatio = 0.4;

  @override
  Future<void> onLoad() async {
    pipeSpawnInterval = (gameRef.size.x * 0.7) / basePipeSpeed;
    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    pipeSpawnTimer += dt;
    if (pipeSpawnTimer > pipeSpawnInterval) {
      pipeSpawnTimer = 0;
      spawnPipes();
    }
  }

  void updateSpeed(double multiplier) {
    currentSpeed = basePipeSpeed * multiplier;
    pipeSpawnInterval = (gameRef.size.x * 0.7) / currentSpeed;
  }

  // ✅ New function: update difficulty based on score
  void updateDifficulty(int score) {
    // Increase difficulty faster — every 5 points
    difficultyLevel = (score ~/ 5) + 1;
    difficultyLevel = difficultyLevel.clamp(1, 20);

    // Narrower gaps each level
    minGapRatio = (0.28 - (0.015 * (difficultyLevel - 1))).clamp(0.12, 0.27);
    maxGapRatio = (0.42 - (0.02 * (difficultyLevel - 1))).clamp(0.18, 0.42);

    // Faster pipes per level
    currentSpeed = basePipeSpeed * (1 + (difficultyLevel - 1) * 0.2);
    pipeSpawnInterval = (gameRef.size.x * 0.7) / currentSpeed;
  }

  void spawnPipes() {
    final screenHeight = gameRef.size.y;
    final pipeWidth = 80.0;

    // Calculate dynamic gap based on difficulty (smaller gap = harder)
    final minGap = screenHeight * minGapRatio;
    final maxGap = screenHeight * maxGapRatio;
    final gap = minGap + random.nextDouble() * (maxGap - minGap);

    // Ensure gap never gets absurdly small (safe minimum)
    final safeGap = gap.clamp(screenHeight * 0.18, screenHeight * 0.5);

    // Define minimum and maximum bottom pipe height
    final minPipeHeight = 50.0;
    final maxBottomHeight =
        screenHeight - Constants.groundHeight - safeGap - minPipeHeight;

    // Random bottom pipe height but more centered — less randomness at high difficulty
    final bottomHeight =
        minPipeHeight +
        (random.nextDouble() * (maxBottomHeight - minPipeHeight)) *
            (1.0 - (difficultyLevel * 0.05)).clamp(0.4, 1.0);

    final topHeight =
        screenHeight - Constants.groundHeight - safeGap - bottomHeight;

    final baseY = screenHeight - bottomHeight - Constants.groundHeight;

    // Add slight horizontal offset randomness at higher difficulty (optional)
    final horizontalOffset = difficultyLevel >= 5
        ? random.nextDouble() * 20 - 10
        : 0.0;

    // Both pipes share same speed
    final bottomPipe = Pipe(
      isTopPipe: false,
      pipeHeight: bottomHeight,
      pipeWidth: pipeWidth,
      posY: baseY + horizontalOffset,
      speed: currentSpeed,
    );

    final topPipe = Pipe(
      isTopPipe: true,
      pipeHeight: topHeight,
      pipeWidth: pipeWidth,
      posY: horizontalOffset,
      speed: currentSpeed,
    );

    gameRef.addAll([topPipe, bottomPipe]);
  }
}
