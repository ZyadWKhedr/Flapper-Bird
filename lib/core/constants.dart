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
  static const double backgroundScrollingSpeed = 45;

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
