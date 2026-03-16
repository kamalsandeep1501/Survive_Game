import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tap_survivor/constants.dart';
import 'package:tap_survivor/pages/game_page.dart';
import 'package:tap_survivor/pages/login_page.dart';
import 'package:tap_survivor/services/auth_service.dart';
import 'package:tap_survivor/widgets/grid_background.dart';

class GameOverPage extends StatelessWidget {
  final int finalScore;
  final bool isNewHighScore;

  const GameOverPage({
    super.key,
    required this.finalScore,
    required this.isNewHighScore,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: GridBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💀', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.redPrimary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  'SCORE: $finalScore',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (isNewHighScore)
                  const Text(
                    'NEW HIGH SCORE! 🏆',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  )
                else if (authService.isLoggedIn)
                  Text(
                    'BEST: ${authService.highScore}',
                    style: AppColors.bodyStyle,
                  )
                else
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                    },
                    child: const Text('Login to save your scores!'),
                  ),

                const SizedBox(height: 60),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bluePrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // Replace with GamePage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const GamePage()),
                    );
                  },
                  child: const Text('PLAY AGAIN', style: AppColors.buttonStyle),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Pop until start page
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Main Menu', style: TextStyle(fontSize: 18, color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
