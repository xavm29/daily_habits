import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/styles.dart';
import 'login_custom.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: _introKey,
      pages: [
        PageViewModel(
          title: "Welcome to Daily Habits! 👋",
          body: "Build better habits and achieve your goals one day at a time. Track your progress and celebrate your wins!",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Create Your Habits 📝",
          body: "Add custom habits with different types: simple checkboxes, quantities, or duration tracking. Set reminders and frequencies!",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Track Your Progress 📊",
          body: "Visualize your streaks, see statistics, and monitor your improvement over time with beautiful charts and insights.",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Earn Rewards 🎁",
          body: "Complete habits to earn coins! Redeem them for real-world rewards. The more consistent you are, the more you earn!",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Join Challenges 🏆",
          body: "Compete with friends, join community challenges, and climb the leaderboards. Stay motivated together!",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Start Your Journey ✨",
          body: "You can start using the app right away, or sign in to sync your data across devices. Let's build better habits!",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
          footer: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _onFinish(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarys,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Get Started', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _onSkip(context),
                  child: const Text('Skip Tutorial'),
                ),
              ],
            ),
          ),
        ),
      ],
      onDone: () => _onFinish(context),
      onSkip: () => _onSkip(context),
      showSkipButton: true,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: AppColors.primarys,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  Widget _buildImage(String assetName) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Image.asset(
        assetName,
        width: 200,
        height: 200,
      ),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: const TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
      ),
      bodyTextStyle: const TextStyle(fontSize: 18.0),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: const EdgeInsets.only(top: 40),
    );
  }

  Future<void> _onFinish(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginCustomScreen()),
    );
  }

  Future<void> _onSkip(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginCustomScreen()),
    );
  }
}
