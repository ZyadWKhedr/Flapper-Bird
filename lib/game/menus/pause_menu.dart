import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flappy_bird/game/game.dart';
import '../../core/ad_helper.dart';

class PauseMenu extends StatefulWidget {
  final FlappyBirdGame game;
  const PauseMenu({super.key, required this.game});

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  BannerAd? _pauseBanner;

  @override
  void initState() {
    super.initState();
    _loadPauseBanner();
  }

  void _loadPauseBanner() {
    final ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _pauseBanner = ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Pause banner failed: ${error.message}');
          ad.dispose();
        },
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _pauseBanner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paused',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.game.resumeGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                widget.game.overlays.remove('PauseMenu');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Exit', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
