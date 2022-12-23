import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';
import '../services/firebase_service.dart';
import '../styles/styles.dart';
import 'home.dart';
import 'login.dart';

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
    _status = await FirebaseService.init();
    setState(() {});

    var user = FirebaseService.instance.user;
    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
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
