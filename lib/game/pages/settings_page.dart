import 'package:flappy_bird/core/ad_helper.dart';
import 'package:flappy_bird/core/constants.dart';
import 'package:flappy_bird/core/services/high_score_service.dart';
import 'package:flappy_bird/game/menus/start_menu.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _highScore = 0;
  int _totalBalloons = 0;
  String _selectedBird = '';

  final List<Map<String, dynamic>> _birdsList = [
    {
      'name': 'Classic Yellow',
      'path': AppImages.birdYellow,
      'req': 0,
      'balloonReq': 0,
    },
    {
      'name': 'Crimson Swift',
      'path': AppImages.birdRed,
      'req': 50,
      'balloonReq': 10,
    },
    {
      'name': 'Cobalt Sky',
      'path': AppImages.birdBlue,
      'req': 150,
      'balloonReq': 25,
    },
    {
      'name': 'Blinky Ghost',
      'path': AppImages.birdGhost,
      'req': 200,
      'balloonReq': 40,
    },
  ];

  final List<Map<String, dynamic>> _trailsList = [
    {
      'id': 'none',
      'name': 'No Trail',
      'desc': 'Clean and classic flight.',
      'icon': Icons.block,
      'color': Colors.grey,
    },
    {
      'id': 'rainbow',
      'name': 'Rainbow Ribbon',
      'desc': 'Vibrant Nyan-cat style rainbow.',
      'icon': Icons.star_purple500_rounded,
      'color': Colors.cyanAccent,
    },
    {
      'id': 'fire',
      'name': 'Fire & Smoke',
      'desc': 'Burning sparks and gray smoke aura.',
      'icon': Icons.local_fire_department,
      'color': Colors.deepOrangeAccent,
    },
    {
      'id': 'sparkle',
      'name': 'Star Sparkles',
      'desc': 'Twinkling golden star particles.',
      'icon': Icons.auto_awesome,
      'color': Colors.amberAccent,
    },
  ];

  String _selectedTrail = 'none';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    setState(() {
      _highScore = HighScoreService.getHighScore();
      _totalBalloons = HighScoreService.getTotalBalloons();
      _selectedBird = HighScoreService.getSelectedBird();
      _selectedTrail = HighScoreService.getSelectedTrail();
    });
  }

  void _selectBird(String path) {
    HighScoreService.saveSelectedBird(path);
    HighScoreService.clearTempBird(); // clear any temporary selections when selecting permanent skin
    setState(() {
      _selectedBird = path;
    });
  }

  void _watchAdToTry(String path) {
    if (AdHelper.preloadedRewardedAd == null) {
      AdHelper.loadRewardedAd();
      return;
    }

    final ad = AdHelper.preloadedRewardedAd!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        AdHelper.preloadedRewardedAd = null;
        AdHelper.loadRewardedAd(); // Load the next one
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        AdHelper.preloadedRewardedAd = null;
        AdHelper.loadRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward: (adWithoutUsed, reward) {
        HighScoreService.saveTempBird(path);
        setState(() {
          _selectedBird = path;
        });
      },
    );
  }

  void _watchAdForTrail(String trailId) {
    if (AdHelper.preloadedRewardedAd == null) {
      AdHelper.loadRewardedAd();
      return;
    }

    final ad = AdHelper.preloadedRewardedAd!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        AdHelper.preloadedRewardedAd = null;
        AdHelper.loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        AdHelper.preloadedRewardedAd = null;
        AdHelper.loadRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward: (adWithoutUsed, reward) async {
        await HighScoreService.incrementTrailAdCount(trailId);
        _loadState();
      },
    );
  }

  void _selectTrail(String trailId) async {
    await HighScoreService.saveSelectedTrail(trailId);
    setState(() {
      _selectedTrail = trailId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ☁️ Looping Horizontal Scrolling Background
          const ScrollingBackground(),

          // Main UI Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar for clean layout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'SKINS & GEAR',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // High Score Badge
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'YOUR HIGHEST SCORE:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            '$_highScore',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.amberAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL BALLOONS POPPED:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            '🎈 $_totalBalloons',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Skins & Trails List View
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    itemCount: _birdsList.length + _trailsList.length,
                    itemBuilder: (context, index) {
                      // 1. Render Bird Skins
                      if (index < _birdsList.length) {
                        final bird = _birdsList[index];
                        final name = bird['name'] as String;
                        final path = bird['path'] as String;
                        final req = bird['req'] as int;
                        final balloonReq = bird['balloonReq'] as int;

                        final scoreMet = _highScore >= req;
                        final isPermanentlyUnlocked = HighScoreService.isBirdSkinUnlocked(path);
                        final isCurrentlySelected = _selectedBird == path;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCurrentlySelected
                                ? Colors.amber.withOpacity(0.12)
                                : Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCurrentlySelected
                                  ? Colors.amberAccent
                                  : Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                            boxShadow: isCurrentlySelected
                                ? [
                                    BoxShadow(
                                      color: Colors.amberAccent.withOpacity(0.08),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SizedBox(
                                  width: 50,
                                  height: 40,
                                  child: Image.asset(
                                    AppImages.flutterPath(path),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (isPermanentlyUnlocked)
                                      const Text(
                                        'UNLOCKED',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.greenAccent,
                                          letterSpacing: 0.5,
                                        ),
                                      )
                                    else ...[
                                      Text(
                                        'REQ SCORE: $req',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: scoreMet ? Colors.greenAccent : Colors.redAccent,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'REQ BALLOONS: 🎈 $balloonReq',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _totalBalloons >= balloonReq ? Colors.greenAccent : Colors.redAccent,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isCurrentlySelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                )
                              else if (isPermanentlyUnlocked)
                                ElevatedButton(
                                  onPressed: () => _selectBird(path),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(color: Colors.white24),
                                    ),
                                  ),
                                  child: const Text(
                                    'SELECT',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )
                              else
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: (scoreMet && _totalBalloons >= balloonReq)
                                          ? () async {
                                              await HighScoreService.spendBalloons(balloonReq);
                                              await HighScoreService.unlockBirdSkin(path);
                                              _loadState();
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amberAccent,
                                        foregroundColor: Colors.black,
                                        disabledBackgroundColor: Colors.white10,
                                        disabledForegroundColor: Colors.white38,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      ),
                                      child: Text(
                                        'BUY (🎈 $balloonReq)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ElevatedButton.icon(
                                      onPressed: () => _watchAdToTry(path),
                                      icon: const Icon(Icons.play_circle_fill, size: 12),
                                      label: const Text(
                                        'TRY 1 RUN',
                                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade900,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }

                      // 2. Render Trail Effects
                      final trailIndex = index - _birdsList.length;
                      final trail = _trailsList[trailIndex];
                      final id = trail['id'] as String;
                      final name = trail['name'] as String;
                      final desc = trail['desc'] as String;
                      final icon = trail['icon'] as IconData;
                      final color = trail['color'] as Color;

                      final isUnlocked = HighScoreService.isTrailUnlocked(id);
                      final isSelected = _selectedTrail == id;
                      final adCount = HighScoreService.getTrailAdCount(id);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (trailIndex == 0) ...[
                            const Padding(
                              padding: EdgeInsets.only(top: 24, bottom: 8),
                              child: Text(
                                'FLIGHT TRAILS & GLITTER',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.amberAccent,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text(
                                'WATCH 5 ADS TO UNLOCK PREMIUM TRAILS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white38,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.12)
                                  : Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : Colors.white.withOpacity(0.15),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, color: color, size: 36),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isUnlocked ? desc : 'WATCH ADS TO UNLOCK: $adCount/5',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked ? Colors.white54 : Colors.amberAccent,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  )
                                else if (isUnlocked)
                                  ElevatedButton(
                                    onPressed: () => _selectTrail(id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(color: Colors.white24),
                                      ),
                                    ),
                                    child: const Text(
                                      'SELECT',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () => _watchAdForTrail(id),
                                    icon: const Icon(Icons.ads_click, size: 16),
                                    label: const Text(
                                      'WATCH AD',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
