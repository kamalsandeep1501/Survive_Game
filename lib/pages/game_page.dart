import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:tap_survivor/constants.dart';
import 'package:tap_survivor/pages/game_over_page.dart';
import 'package:tap_survivor/services/auth_service.dart';
import 'package:tap_survivor/widgets/grid_background.dart';

class ActiveStone {
  double x;
  double y;
  bool isHeal;
  
  ActiveStone({required this.x, required this.y, this.isHeal = false});
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final Random _random = Random();

  List<ActiveStone> stones = [];
  
  double currentSpeed = 2.5; 
  double maxSpeed = 7.0;
  
  Duration spawnInterval = const Duration(milliseconds: 1800);
  final Duration minSpawnInterval = const Duration(milliseconds: 700);
  
  Duration _elapsedTime = Duration.zero;
  Duration _lastSpawnTime = Duration.zero;
  
  int score = 0;
  int misses = 0;
  final int maxMisses = 8;
  
  final double stoneSize = 36.0;

  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    // Delay start slightly so layout dimensions are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ticker.start();
    });
  }

  void _onTick(Duration elapsed) {
    if (isGameOver) return;

    // Use dt if needed, currently we use fixed speed per tick
    _elapsedTime = elapsed;
    
    // Spawn new stones logic
    if (elapsed - _lastSpawnTime > spawnInterval) {
      _spawnStone();
      _lastSpawnTime = elapsed;
      
      // Increase difficulty smoothly
      currentSpeed += 0.05;
      if (currentSpeed > maxSpeed) {
        currentSpeed = maxSpeed;
      }
      
      int newIntervalMs = spawnInterval.inMilliseconds - 20;
      if (newIntervalMs < minSpawnInterval.inMilliseconds) {
        newIntervalMs = minSpawnInterval.inMilliseconds;
      }
      spawnInterval = Duration(milliseconds: newIntervalMs);
    }
    
    _updateStones();
  }
  
  void _spawnStone() {
    if (!mounted) return;
    final screenWidth = MediaQuery.of(context).size.width;
    // ensure it spawns fully within bounds
    final x = _random.nextDouble() * (screenWidth - stoneSize);
    
    // 10% chance to spawn a heal orb instead of a normal stone
    bool isHealOrb = _random.nextDouble() < 0.10;
    
    // spawn from just below the top edge
    stones.add(ActiveStone(x: x, y: 0, isHeal: isHealOrb));
  }
  
  void _updateStones() {
    if (!mounted) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomZoneHeight = 80.0 + ((maxMisses - misses) * 18.0);
    final blueBaseTopY = screenHeight - bottomZoneHeight;
    
    setState(() {
      for (int i = stones.length - 1; i >= 0; i--) {
        stones[i].y += currentSpeed;
        
        // Check collision with the top of the blue base
        if (stones[i].y + stoneSize >= blueBaseTopY) {
          final stone = stones[i];
          stones.removeAt(i);
          
          if (!stone.isHeal) {
             // Red stones damage the base
             _handleMiss();
          }
          // If it's a heal orb, missing it just makes it disappear harmlessly
        }
      }
    });
  }

  void _handleMiss() {
    misses++;
    if (misses >= maxMisses) {
      _gameOver();
    }
  }

  void _handleTap(int index) {
    if (isGameOver) return;
    setState(() {
      final tappedStone = stones[index];
      stones.removeAt(index);
      
      if (tappedStone.isHeal) {
        // Heal orb tapped: restore 1 miss (if not already at max HP)
        if (misses > 0) {
          misses--;
        }
        score += 5; // Smaller score for heals
      } else {
        // Normal stone tapped
        score += 10;
      }
    });
  }

  Future<void> _gameOver() async {
    isGameOver = true;
    _ticker.stop();
    
    final authService = Provider.of<AuthService>(context, listen: false);
    bool isNewHigh = false;
    
    if (authService.isLoggedIn && score > authService.highScore) {
      isNewHigh = true;
      await authService.updateHighScore(score);
    }
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameOverPage(
          finalScore: score,
          isNewHighScore: isNewHigh,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomZoneHeight = 80.0 + ((maxMisses - misses) * 18.0);
    final redZoneHeight = 30.0 + (misses * 18.0); // Base red zone thickness at top

    return Scaffold(
      body: SizedBox.expand(
        child: GridBackground(
          child: Stack(
            children: [
            // Stones (drawn behind bases)
            ...List.generate(stones.length, (i) {
              final stone = stones[i];
              final stoneColor = stone.isHeal ? AppColors.blueLight : AppColors.redPrimary;
              
              return Positioned(
                left: stone.x,
                top: stone.y,
                child: GestureDetector(
                  onTapDown: (_) => _handleTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: stoneSize,
                    height: stoneSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stoneColor,
                      boxShadow: [
                        BoxShadow(
                          color: stoneColor.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: stone.isHeal
                        ? const Icon(Icons.favorite, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              );
            }),

            // Red Creep Base
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: redZoneHeight,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.redLight, width: 2)),
                  gradient: LinearGradient(
                    colors: [Color(0xFFB71C1C), Color(0xAAE53935)], // Darker at top, lighter at bottom
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Blue Player Base
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: bottomZoneHeight,
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.blueLight, width: 2)),
                  gradient: LinearGradient(
                    colors: [Color(0xAA1565C0), Color(0xFF0D47A1)], // Blue gradient
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🛡️',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),

            // HUD
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // HP Bar HUD
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite, color: AppColors.redLight, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'HP: ${maxMisses - misses}',
                            style: AppColors.scoreStyle.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                    ),

                    // Top Right Score HUD
                    Consumer<AuthService>(
                      builder: (context, authService, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('SCORE: $score', style: AppColors.scoreStyle),
                              if (authService.isLoggedIn)
                                Text(
                                  'BEST: ${authService.highScore}',
                                  style: AppColors.scoreStyle.copyWith(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
