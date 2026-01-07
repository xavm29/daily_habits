import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_data.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../styles/styles.dart';
import 'home.dart';
import 'login_custom.dart';
import 'onboarding_screen.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String _status = "Inicialitzant l'app...";

  @override
  void initState() {
    super.initState();
    workFlow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarys,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/icon.png"),
            const SizedBox(
              height: 32,
            ),
            const CircularProgressIndicator(
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }

  void workFlow() async {
    // Initialize local storage
    await LocalStorageService.instance.initialize();

    // Firebase is already initialized in main.dart, but we keep this for compatibility
    // if FirebaseService.init does other setup.
    _status = await FirebaseService.init();
    if (mounted) setState(() {});

    // Check if onboarding is complete
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (!onboardingComplete) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
      return;
    }

    // Wait for authentication state to be determined
    // This is crucial for Google Sign In persistence
    User? user = await FirebaseAuth.instance.authStateChanges().first;

    if (user == null) {
      // Check if user has local data
      final hasLocalData = await LocalStorageService.instance.hasLocalData();

      if (!mounted) return;

      if (hasLocalData) {
        // User has been using the app without registration, go to home
        var userData = Provider.of<UserData>(context, listen: false);
        final localTasks = LocalStorageService.instance.getLocalCompletedTasks();
        userData.tasks = localTasks;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        // New user, show login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginCustomScreen()),
        );
      }
    } else {
      if (!mounted) return;
      var userData = Provider.of<UserData>(context, listen: false);
      
      // Load user data
      try {
        final tasks = await FirebaseService.instance.getCompletedTasks();
        userData.tasks = tasks;
      } catch (e) {
        print('Error loading tasks: $e');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Home()));
    }
  }
}
