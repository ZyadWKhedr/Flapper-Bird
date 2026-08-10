import 'dart:async';
import 'package:flappy_bird/core/app_router.dart';
import 'package:flappy_bird/core/constants.dart';
import 'package:flutter/material.dart';

import 'package:flappy_bird/core/ad_helper.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _progress = 0.0;
  String _loadingMessage = 'INITIALIZING SYSTEM...';
  late Timer _messageTimer;
  late Timer _progressTimer;

  final List<String> _loadingMessages = [
    'LOADING FLAPPING PHYSICS...',
    'POLISHING RETRO PIXELS...',
    'PREPARING SPONSORS & ADS...',
    'FEEDING THE GHOSTS...',
    'WARMING UP THE WINGS...',
    'READY TO SOAR!'
  ];
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Start preloading all ads immediately
    AdHelper.preloadAllAds();
    _startLoading();
  }

  void _startLoading() {
    // Message rotation
    _messageTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
          _loadingMessage = _loadingMessages[_messageIndex];
        });
      }
    });

    final startTime = DateTime.now();

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
        
        // Calculate progress based on actual loaded ads
        double adProgress = 0.0;
        if (AdHelper.preloadedBannerAd != null) adProgress += 0.33;
        if (AdHelper.preloadedInterstitialAd != null) adProgress += 0.33;
        if (AdHelper.preloadedRewardedAd != null) adProgress += 0.34;

        // Force complete if safety timeout (5 seconds) is reached or all ads loaded
        if (elapsedMs >= 5000 || adProgress >= 1.0) {
          setState(() {
            _progress = 1.0;
          });
          _progressTimer.cancel();
          _messageTimer.cancel();
          _goToStartMenu();
        } else {
          // Smoothly animate towards target progress
          double timeProgress = elapsedMs / 5000.0;
          double targetProgress = adProgress > timeProgress ? adProgress : timeProgress;
          setState(() {
            if (_progress < targetProgress) {
              _progress += 0.02;
              if (_progress > targetProgress) _progress = targetProgress;
            }
          });
        }
      }
    });
  }

  void _goToStartMenu() {
    Navigator.pushReplacementNamed(context, AppRouter.startMenu);
  }

  @override
  void dispose() {
    _messageTimer.cancel();
    _progressTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111417), // Sleek, modern dark background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                AppImages.flutterPath(AppImages.logo),
                width: 240,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'FLAPPER BIRD',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                      letterSpacing: 2,
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 12,
                  width: double.infinity,
                  color: Colors.grey.shade900,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber, Colors.orangeAccent],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Message Text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _loadingMessage,
                  key: ValueKey<String>(_loadingMessage),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              
              // Percentage text
              Text(
                '${(_progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
