class Constants {
  // Bird start position
  static const double birdStartX = 80;
  static const double birdStartY = 300; // move bird to middle for better start
  static const double birdWidth = 70;
  static const double birdHeight = 50;

  // Physics
  static const double gravity = 400; // slightly stronger gravity
  static const double jumpStrength = -250; // slightly stronger jump
  static const double velocity = 0;

  // Ground
  static const double groundStartX = 0;
  static const double groundStartY = 750; // adjust if screen size changes
  static const double groundHeight = 150;
  static const double groundScrollingSpeed = 65;

  // Background
  static const double backgroundScrollingSpeed = 25;

  // Pipes
  static const double pipeScrollingSpeed = 65; // moderate speed
  static const double minPipeVerticalGap = birdHeight + 80; // min vertical gap
  static const double maxPipeVerticalGap = birdHeight + 180; // max vertical gap
  static const double minPipeHorizontalGap = 300; // min horizontal distance
  static const double maxPipeHorizontalGap = 450; // max horizontal distance
  static const double pipeWidth = 80;

  // Game
  static double score = 0;
  static const String version = '1.0.0';
}

class AppImages {
  // Birds
  static const String birdYellow = 'birds/bird_yellow.png';
  static const String birdRed = 'birds/bird_red.png';
  static const String birdBlue = 'birds/bird_blue.png';
  static const String birdGhost = 'birds/ghost.png';

  // Backgrounds
  static const String backgroundPink = 'backgrounds/pink.jpg';
  static const String backgroundPurple = 'backgrounds/purple.jpg';
  static const String backgroundBlueClouds = 'backgrounds/blue_clouds.jpg';
  static const String backgroundCyanClouds = 'backgrounds/cyan_clouds.jpg';
  static const String backgroundDefault = 'backgrounds/background.png';
  static const String backgroundCity = 'backgrounds/retro_city.png';

  // Pipes
  static const String topPipe = 'pipes/top_pipe.png';
  static const String bottomPipe = 'pipes/bottom_pipe.png';
  static const String redPipe = 'pipes/red_pipe.png';

  // Environment & UI
  static const String ground = 'environment/ground.png';
  static const String logo = 'ui/logo.png';
  static const String gameover = 'ui/gameover.png';

  // Helper for Flutter widgets
  static String flutterPath(String path) => 'assets/images/$path';
}
