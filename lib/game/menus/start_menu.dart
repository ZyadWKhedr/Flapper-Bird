import 'package:flappy_bird/core/app_router.dart';
import 'package:flappy_bird/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flappy_bird/core/ad_helper.dart';
import 'package:flappy_bird/core/services/high_score_service.dart';
import 'package:audioplayers/audioplayers.dart';

class StartMenu extends StatefulWidget {
  const StartMenu({super.key});

  @override
  State<StartMenu> createState() => _StartMenuState();
}

class _StartMenuState extends State<StartMenu> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  
  late final AudioPlayer _audioPlayer;
  bool _musicEnabled = true;

  final List<Map<String, String>> _birds = [
    {'name': 'Classic Yellow', 'path': AppImages.birdYellow},
    {'name': 'Crimson Swift', 'path': AppImages.birdRed},
    {'name': 'Cobalt Sky', 'path': AppImages.birdBlue},
    {'name': 'Blinky Ghost', 'path': AppImages.birdGhost},
  ];
  int _selectedBirdIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadSelectedBird();
    
    // Initialize background audio player
    _audioPlayer = AudioPlayer();
    _musicEnabled = HighScoreService.isMusicEnabled();
    if (_musicEnabled) {
      _startMusic();
    }
  }

  Future<void> _startMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/background.mp3'));
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  void _toggleMusic() async {
    setState(() {
      _musicEnabled = !_musicEnabled;
    });
    await HighScoreService.saveMusicEnabled(_musicEnabled);
    if (_musicEnabled) {
      _startMusic();
    } else {
      await _audioPlayer.stop();
    }
  }

  void _loadSelectedBird() {
    final savedPath = HighScoreService.getSelectedBird();
    final index = _birds.indexWhere((bird) => bird['path'] == savedPath);
    if (index != -1) {
      setState(() {
        _selectedBirdIndex = index;
      });
    }
  }

  void _selectBird(int index) {
    setState(() {
      _selectedBirdIndex = index;
    });
    HighScoreService.saveSelectedBird(_birds[index]['path']!);
  }

  void _loadBannerAd() {
    final ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
            _bannerAd = ad as BannerAd;
          });
          debugPrint('✅ Start Menu banner loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() => _isAdLoaded = false);
          debugPrint('❌ Start Menu banner failed: ${error.message}');
        },
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startGame() {
    _audioPlayer.stop();
    Navigator.pushNamed(context, AppRouter.game).then((_) {
      if (_musicEnabled) {
        _startMusic();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ☁️ Looping Horizontal Scrolling Background
          const ScrollingBackground(),

          // 🔊 Music Toggle Icon Button
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  icon: Icon(
                    _musicEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    color: _musicEnabled ? Colors.amberAccent : Colors.white60,
                    size: 24,
                  ),
                  onPressed: _toggleMusic,
                ),
              ),
            ),
          ),

          // Main UI Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🎮 Floating Styled Title
                    const FloatingTitle(),
                    const SizedBox(height: 10),

                    // High Score Badge
                    Builder(
                      builder: (context) {
                        final highScore = HighScoreService.getHighScore();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.amberAccent.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            'BEST SCORE: $highScore',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amberAccent,
                              letterSpacing: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 35),

                    // Glowing Arcade Card Container
                    Container(
                      width: 320,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.amberAccent.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amberAccent.withOpacity(0.08),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Selected Character Preview Card
                          Builder(
                            builder: (context) {
                              final selectedPath =
                                  HighScoreService.getSelectedBird();
                              final birdMap = _birds.firstWhere(
                                (b) => b['path'] == selectedPath,
                                orElse: () => _birds[0],
                              );
                              final birdName = birdMap['name']!;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 35,
                                      child: Image.asset(
                                        AppImages.flutterPath(selectedPath),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'SELECTED BIRD',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white38,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            birdName.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // 🕹️ Play Button with 3D tactile press
                          ArcadeButton(
                            label: 'START GAME',
                            icon: Icons.play_arrow_rounded,
                            color: Colors.amber,
                            isPrimary: true,
                            onPressed: _startGame,
                          ),
                          const SizedBox(height: 12),

                          // 🎨 Skins Button
                          ArcadeButton(
                            label: 'SKINS & GEAR',
                            icon: Icons.grid_view_rounded,
                            color: Colors.blueGrey.shade800,
                            isPrimary: false,
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRouter.settings,
                              );
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🟩 Bottom ad banner
          if (_isAdLoaded)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// ☁️ Horizontally Looping scrolling background widget
// ----------------------------------------------------------------------------
class ScrollingBackground extends StatefulWidget {
  const ScrollingBackground({super.key});

  @override
  State<ScrollingBackground> createState() => _ScrollingBackgroundState();
}

class _ScrollingBackgroundState extends State<ScrollingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final offset = _controller.value * screenWidth;

        return Stack(
          children: [
            Positioned(
              left: -offset,
              top: 0,
              bottom: 0,
              width: screenWidth + 2,
              child: Image.asset(
                AppImages.flutterPath(AppImages.backgroundDefault),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: screenWidth - offset,
              top: 0,
              bottom: 0,
              width: screenWidth + 2,
              child: Image.asset(
                AppImages.flutterPath(AppImages.backgroundDefault),
                fit: BoxFit.cover,
              ),
            ),
            // Moody dark overlay gradient for high readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ----------------------------------------------------------------------------
// 🎮 Bouncing / Floating styled arcade title
// ----------------------------------------------------------------------------
class FloatingTitle extends StatefulWidget {
  const FloatingTitle({super.key});

  @override
  State<FloatingTitle> createState() => _FloatingTitleState();
}

class _FloatingTitleState extends State<FloatingTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Text(
            'FLAPPER BIRDY',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.amberAccent,
              shadows: [
                Shadow(
                  offset: const Offset(4, 4),
                  blurRadius: 0.0,
                  color: Colors.brown.shade900,
                ),
                const Shadow(
                  offset: Offset(-2, -2),
                  blurRadius: 0.0,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------------------------
// 🕹️ 3D Arcade physical-press button widget
// ----------------------------------------------------------------------------
class ArcadeButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isPrimary;

  const ArcadeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<ArcadeButton> createState() => _ArcadeButtonState();
}

class _ArcadeButtonState extends State<ArcadeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final shadowColor = widget.color == Colors.amber
        ? Colors.orange.shade900
        : Colors.blueGrey.shade900;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(
          top: _isPressed ? 6 : 0,
          bottom: _isPressed ? 0 : 6,
        ),
        height: 52,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? []
              : [BoxShadow(color: shadowColor, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.isPrimary ? Colors.black : Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.isPrimary ? Colors.black : Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
