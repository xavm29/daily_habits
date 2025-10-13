import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../styles/styles.dart';
import 'home.dart';
import 'login_custom.dart';

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

    _status = await FirebaseService.init();
    setState(() {});

    var user = FirebaseService.instance.user;
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
      FirebaseService.instance.getCompletedTasks().then((value) {
        userData.tasks = value;
      });

      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Home()));
    }
  }
}
