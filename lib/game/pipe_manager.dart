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
    // Every 10 points, increase difficulty (up to level 10)
    difficultyLevel = (score ~/ 10) + 1;
    difficultyLevel = difficultyLevel.clamp(1, 10);

    // Smaller gaps as difficulty increases
    minGapRatio = 0.25 - (0.03 * (difficultyLevel - 1));
    maxGapRatio = 0.4 - (0.05 * (difficultyLevel - 1));

    // Slightly faster pipe movement
    updateSpeed(1.0 + (0.15 * (difficultyLevel - 1)));
  }

  void spawnPipes() {

    
    final screenHeight = gameRef.size.y;
    final pipeWidth = 80.0;

    final minGap = screenHeight * minGapRatio;
    final maxGap = screenHeight * maxGapRatio;
    final gap = minGap + random.nextDouble() * (maxGap - minGap);

    final minPipeHeight = 50.0;
    final maxBottomHeight =
        screenHeight - Constants.groundHeight - gap - minPipeHeight;

    final bottomHeight =
        minPipeHeight + random.nextDouble() * (maxBottomHeight - minPipeHeight);

    final topHeight =
        screenHeight - Constants.groundHeight - gap - bottomHeight;

    final baseY = screenHeight - bottomHeight - Constants.groundHeight;

    final oscillationAmplitude = 15 + random.nextDouble() * 20;
    final oscillationSpeed = 1.2 + random.nextDouble() * 1.8;
    final groupPhase = random.nextDouble() * pi * 2; // random start phase

    // Both pipes share the same oscillation parameters
    final bottomPipe =
        Pipe(
            isTopPipe: false,
            pipeHeight: bottomHeight,
            pipeWidth: pipeWidth,
            posY: baseY,
            speed: currentSpeed,
          )
          ..oscillationAmplitude = oscillationAmplitude
          ..oscillationSpeed = oscillationSpeed
          ..phase = groupPhase;

    final topPipe =
        Pipe(
            isTopPipe: true,
            pipeHeight: topHeight,
            pipeWidth: pipeWidth,
            posY: 0,
            speed: currentSpeed,
          )
          ..oscillationAmplitude = oscillationAmplitude
          ..oscillationSpeed = oscillationSpeed
          ..phase = groupPhase;
          

    gameRef.addAll([topPipe, bottomPipe]);
  }
}
