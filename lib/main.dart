import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'models/user_data.dart';
import 'providers/theme_provider.dart';
import 'screens/splash.dart';
import 'services/crashlytics_service.dart';
import 'services/analytics_service.dart';
import 'services/sound_service.dart';
import 'services/vibration_service.dart';
import 'services/challenge_service.dart';
import 'utils/date_formatter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  await CrashlyticsService.instance.initialize();

  // Analytics is initialized automatically with FirebaseAnalytics.instance

  // Initialize Sound and Vibration services
  await SoundService.instance.initialize();
  await VibrationService.instance.initialize();

  // Initialize Date Formatter
  await DateFormatter.loadFormat();

  // Initialize default challenges (only creates them if they don't exist)
  try {
    await ChallengeService.instance.initializeDefaultChallenges();
  } catch (e) {
    print('Error initializing default challenges: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserData()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorObservers: [
              AnalyticsService.instance.observer,
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('es'),
            ],
            title: 'Daily Habits',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const Splash(),
          );
        },
      ),
    );
  }
}
