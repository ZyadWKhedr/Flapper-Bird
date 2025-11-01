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

  void spawnPipes() {
    final screenHeight = gameRef.size.y;
    final pipeWidth = 80.0;

    final minGap = screenHeight * 0.25;
    final maxGap = screenHeight * 0.4;
    final gap = minGap + random.nextDouble() * (maxGap - minGap);

    final minPipeHeight = 50.0;
    final maxBottomHeight =
        screenHeight - Constants.groundHeight - gap - minPipeHeight;

    final bottomHeight =
        minPipeHeight + random.nextDouble() * (maxBottomHeight - minPipeHeight);

    final topHeight =
        screenHeight - Constants.groundHeight - gap - bottomHeight;

    final bottomPipe = Pipe(
      isTopPipe: false,
      pipeHeight: bottomHeight,
      pipeWidth: pipeWidth,
      posY: screenHeight - bottomHeight - Constants.groundHeight,
      speed: currentSpeed,
    );

    final topPipe = Pipe(
      isTopPipe: true,
      pipeHeight: topHeight,
      pipeWidth: pipeWidth,
      posY: 0,
      speed: currentSpeed,
    );

    gameRef.addAll([topPipe, bottomPipe]);
  }
}
