import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tap_survivor/constants.dart';
import 'package:tap_survivor/pages/game_page.dart';
import 'package:tap_survivor/pages/login_page.dart';
import 'package:tap_survivor/pages/signup_page.dart';
import 'package:tap_survivor/services/auth_service.dart';
import 'package:tap_survivor/widgets/grid_background.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: SizedBox.expand(
        child: GridBackground(
          child: SafeArea(
            child: Stack(
              children: [
              // Top Right Auth/User Info
              Positioned(
                top: 16,
                right: 16,
                child: authService.isLoggedIn
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${authService.username ?? 'Current'} 🏆 ${authService.highScore}',
                            style: AppColors.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => authService.logout(),
                            child: const Text('Logout', style: TextStyle(color: AppColors.redLight)),
                          )
                        ],
                      )
                    : Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                            child: const Text('Login', style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
              ),
              
              // Center Title and Start Button
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title with Gradient Shader
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.blueLight, AppColors.bluePrimary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'TAP\nSURVIVOR',
                        textAlign: TextAlign.center,
                        style: AppColors.titleStyle,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Animated Start Button
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.bluePrimary.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                )
                              ],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _startGame,
                        child: const Text('START GAME', style: AppColors.buttonStyle),
                      ),
                    ),

                    const SizedBox(height: 40),
                    // Hint Text
                    Text(
                      authService.isLoggedIn 
                        ? "Score will be saved automatically!"
                        : "Play as guest or login to save your score",
                      style: AppColors.bodyStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
