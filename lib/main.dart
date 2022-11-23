import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'models/user_data.dart';
import 'screens/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserData(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            colorSchemeSeed:AppColors.primarys,
            textTheme: GoogleFonts.rubikTextTheme()
        ),
        home: const Splash(),
      ),
    );
  }
}

