import 'package:flutter/material.dart';
import 'package:timeboxing/screens/home_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onToggleLanguage;
  
  const SplashScreen({
    super.key,
    required this.onToggleLanguage,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isTextVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isTextVisible = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  onToggleLanguage: widget.onToggleLanguage,
                ),
              ),
            );
          }
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animation
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Lottie.asset(
                'assets/animations/time_management.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  _controller.forward();
                },
              ),
            ),
            const SizedBox(height: 30),
            // Animated text
            if (_isTextVisible)
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    isArabic ? 'تايم بوكسينج' : 'TimeBoxing',
                    textStyle: const TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            const SizedBox(height: 10),
            if (_isTextVisible)
              AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    isArabic ? 'نظم وقتك بذكاء' : 'Smart Time Management',
                    textStyle: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.white70,
                    ),
                    duration: const Duration(milliseconds: 2000),
                  ),
                ],
                totalRepeatCount: 1,
              ),
          ],
        ),
      ),
    );
  }
}