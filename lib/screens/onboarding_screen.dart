import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/styles.dart';
import 'login_custom.dart';
import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IntroductionScreen(
      key: _introKey,
      pages: [
        PageViewModel(
          title: l10n.welcomeToApp,
          body: l10n.onboardingBody1,
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: l10n.onboardingTitle1,
          body: l10n.onboardingBody1,
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: l10n.onboardingTitle2,
          body: l10n.onboardingBody2,
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: l10n.onboardingTitle3,
          body: l10n.onboardingBody3,
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: l10n.getStarted,
          body: l10n.youCanRegisterLater,
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
                  child: Text(l10n.getStarted, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _onSkip(context),
                  child: Text(l10n.skip),
                ),
              ],
            ),
          ),
        ),
      ],
      onDone: () => _onFinish(context),
      onSkip: () => _onSkip(context),
      showSkipButton: true,
      skip: Text(l10n.skip, style: const TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: Text(l10n.next, style: const TextStyle(fontWeight: FontWeight.w600)),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = (constraints.maxWidth * 0.5).clamp(150.0, 250.0);
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primarys,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              assetName,
              fit: BoxFit.contain,
            ),
          );
        },
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
