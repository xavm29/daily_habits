import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
  ];

  // App general
  String get appName;
  String get home;
  String get settings;
  String get profile;
  String get logout;
  String get cancel;
  String get save;
  String get delete;
  String get edit;
  String get create;
  String get loading;
  String get error;
  String get success;
  String get confirm;
  String get yes;
  String get no;

  // Authentication
  String get welcomeBack;
  String get signIn;
  String get signUp;
  String get signInToContinue;
  String get signUpToSaveProgress;
  String get createAccount;
  String get email;
  String get password;
  String get continueWithGoogle;
  String get skipForNow;
  String get youCanRegisterLater;
  String get alreadyHaveAccount;
  String get dontHaveAccount;
  String get signInButton;
  String get signUpButton;
  String get or;

  // Validation
  String get pleaseEnterEmail;
  String get pleaseEnterValidEmail;
  String get pleaseEnterPassword;
  String get passwordMustBe6Characters;

  // Home Screen
  String get toBeDone;
  String get completed;
  String get noGoalsForToday;
  String get target;
  String get track;

  // Goals
  String get createGoal;
  String get editGoal;
  String get goalTitle;
  String get goalDescription;
  String get goalType;
  String get checkbox;
  String get quantitative;
  String get duration;
  String get frequency;
  String get daily;
  String get weekly;
  String get selectDays;
  String get monday;
  String get tuesday;
  String get wednesday;
  String get thursday;
  String get friday;
  String get saturday;
  String get sunday;
  String get startDate;
  String get endDate;
  String get targetValue;
  String get unit;
  String get reminder;
  String get noReminder;
  String get setReminder;

  // Challenges
  String get challenges;
  String get activeChallenges;
  String get completedChallenges;
  String get createCustomChallenge;
  String get challengeTitle;
  String get challengeDescription;
  String get durationDays;
  String get targetCount;
  String get category;
  String get joinChallenge;
  String get leaveChallenge;
  String get daysLeft;
  String get participants;
  String get active;

  // Categories
  String get general;
  String get consistency;
  String get health;
  String get productivity;

  // Rewards
  String get rewards;
  String get myCoins;
  String get earnedCoins;
  String get spentCoins;
  String get availableCoins;
  String get redeemReward;
  String get cost;

  // Achievements
  String get achievements;
  String get unlocked;
  String get locked;
  String get progress;

  // Settings
  String get darkMode;
  String get language;
  String get notifications;
  String get dataExport;
  String get exportData;
  String get importData;
  String get syncData;
  String get about;
  String get version;
  String get privacyPolicy;
  String get termsOfService;

  // Notifications
  String get notificationTitle;
  String get notificationBody;
  String get reminderNotification;

  // Social
  String get friends;
  String get addFriend;
  String get sendFriendRequest;
  String get acceptFriendRequest;
  String get friendRequests;
  String get compareProgress;

  // Statistics
  String get statistics;
  String get currentStreak;
  String get longestStreak;
  String get totalCompleted;
  String get completionRate;
  String get thisWeek;
  String get thisMonth;
  String get allTime;

  // Messages
  String get greatJob;
  String get keepItUp;
  String get perfectDay;
  String get taskCompleted;
  String get goalAchieved;
  String get challengeJoined;
  String get challengeCompleted;
  String get rewardRedeemed;
  String get dataExported;
  String get dataImported;
  String get friendRequestSent;
  String get friendRequestAccepted;

  // Errors
  String get errorLoadingData;
  String get errorSavingData;
  String get errorDeletingData;
  String get errorSigningIn;
  String get errorSigningUp;
  String get errorSigningOut;
  String get errorNetwork;
  String get errorUnknown;

  // Prompts
  String get deleteGoalPrompt;
  String get deleteChallengePrompt;
  String get leaveAppPrompt;
  String get signOutPrompt;

  // Onboarding
  String get welcomeToApp;
  String get onboardingTitle1;
  String get onboardingBody1;
  String get onboardingTitle2;
  String get onboardingBody2;
  String get onboardingTitle3;
  String get onboardingBody3;
  String get getStarted;
  String get skip;
  String get next;
  String get back;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'es':
        return AppLocalizationsEs();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
