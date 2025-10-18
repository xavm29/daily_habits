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

  // Additional translations for screens
  String get days;
  String get level;
  String get user;
  String get onFire;
  String get completedPlural;
  String get noRankingsYet;
  String get noStreaksYet;
  String get noActivityThisWeek;
  String get completeHabitsToSeeRankings;
  String get you;
  String get weeklyActivity;
  String get totalOverview;
  String get activeGoals;
  String get daysActive;
  String get weeklyCompletion;
  String get ofGoalsCompleted;
  String get exportCSV;
  String get exportPDF;
  String get downloadYourHabitsData;
  String get csvExportedSuccessfully;
  String get errorExportingCSV;
  String get pdfReportExportedSuccessfully;
  String get errorExportingPDF;
  String get leaderboard;
  String get xp;
  String get streaks;
  String get quantity;
  String get monthly;
  String get repeatEveryDay;
  String get selectYourTimeReminder;
  String get selectYourEndDate;
  String get pleaseEnterGoal;
  String get pleaseSelectEndDate;
  String get pleaseSelectReminderTime;
  String get pleaseEnterTargetValue;
  String get goalCreatedWithReminder;
  String get setYourGoals;
  String get goal;
  String get unitMin;
  String get appearance;
  String get switchBetweenLightAndDark;
  String get showCompletedHabits;
  String get displayCompletedHabitsInList;
  String get showProgressBars;
  String get displayProgressIndicators;
  String get feedback;
  String get soundEffects;
  String get playSoundsWhenCompletingHabits;
  String get vibration;
  String get vibrateOnHabitCompletion;
  String get calendar;
  String get weekStartsOn;
  String get dateFormat;
  String get dataAndPrivacy;
  String get clearAllData;
  String get thisCannotBeUndone;
  String get clearAllDataQuestion;
  String get thisWillDeleteAllYourData;
  String get clearAll;
  String get dataClearedSuccessfully;
  String get errorClearingData;
  String get available;
  String get redeemed;
  String get availableCoinsLabel;
  String get totalEarned;
  String get spent;
  String get noRewardsRedeemedYet;
  String get completeHabitsToEarnCoins;
  String get needMoreCoins;
  String get redeem;
  String get redeemRewardQuestion;
  String get costCoins;
  String get youWillHaveCoinsLeft;
  String get rewardRedeemedEnjoy;
  String get failedToRedeemReward;
  String get insufficientCoins;
  String get youNeedMoreCoins;
  String get justNow;
  String get minuteAgo;
  String get minutesAgo;
  String get hourAgo;
  String get hoursAgo;
  String get dayAgo;
  String get daysAgo;
  String get name;
  String get thisWeekLabel;
  String get totalHours;
  String get switchTheme;
  String get closeSession;

  // Reminder Settings
  String get reminderSettings;
  String get smartReminders;
  String get letUsRemindYou;
  String get defaultReminderTime;
  String get smartRemindersDescription;
  String get streakAlerts;
  String get getMotivatedOnStreak;
  String get eveningReminder;
  String get remindIncompleteHabits;
  String get howSmartRemindersWork;
  String get smartRemindersExplanation;
  String get reminderTimeUpdated;

  // Achievements
  String get badges;
  String get xpToNextLevel;
  String get earned;
  String get close;

  // Friends
  String get myFriends;
  String get requests;
  String get noFriendsYet;
  String get addFriendsToSeeProgress;
  String get dayStreak;
  String get removeFriend;
  String get removeFriendQuestion;
  String get remove;
  String get friendRemoved;
  String get noPendingRequests;
  String get sent;
  String get friendRequestAcceptedMessage;
  String get friendRequestRejected;
  String get addFriendTitle;
  String get searchByEmail;
  String get friendRequestSentMessage;
  String get add;
  String get errorSearchingUsers;
  String get ago;

  // Home Screen Messages
  String greatJobCoins(int coins);
  String completedWithCoins(String value, String unit, int coins);

  // Error Messages
  String errorSigningInMessage(String error);
  String errorMessage(String error);

  // Challenges
  String get myChallenges;
  String get allChallenges;
  String get noChalllengesYet;
  String get goToAllChallenges;
  String get noChallengesAvailable;
  String get challengesRecreated;
  String get daysLabel;
  String get participantsLabel;
  String get streakLabel;
  String get daysCompleted;
  String get leftChallenge;
  String get joinedChallenge;
  String get daysRemaining;
  String get challengeTitleLabel;
  String get challengeTitleHint;
  String get descriptionLabel;
  String get descriptionHint;
  String get durationDaysLabel;
  String get durationHint;
  String get targetDaysLabel;
  String get targetDaysHint;
  String get categoryLabel;
  String get createButton;
  String get pleaseEnterTitle;
  String get pleaseEnterDescription;
  String get pleaseEnterValidDuration;
  String get pleaseEnterValidTarget;
  String challengeCreatedMessage(String title);

  // Challenge Detail Screen
  String get noChallengeProgress;
  String get completedDaysLabel;
  String get streak;
  String get remaining;
  String get completedToday;
  String get markTodayLabel;
  String get markAsCompleted;
  String get dayMarkedCompleted;
  String get yourProgress;
  String get daysCompletedProgress;
  String get successRate;
  String get startDateLabel;
  String get endDateLabel;
  String get challengeCalendar;

  // Registration Dialog
  String get saveYourProgress;
  String get youveBeenDoingGreat;
  String get registerNowTo;
  String get syncYourDataAcrossDevices;
  String get neverLoseYourProgress;
  String get connectWithFriends;
  String get joinChallengesText;
  String get backupYourHabits;
  String get maybeLater;
  String get registerNow;

  // Review Dialog
  String get enjoyingDailyHabits;
  String get wedLoveToHearYourFeedback;
  String get yourReviewHelpsUs;
  String get noThanks;
  String get rateNow;

  // Default Challenge Translations
  String get challenge7DayConsistency;
  String get challenge7DayConsistencyDesc;
  String get challenge30DayFitness;
  String get challenge30DayFitnessDesc;
  String get challengeMorningRoutineMaster;
  String get challengeMorningRoutineMasterDesc;
  String get challenge21DayReading;
  String get challenge21DayReadingDesc;
  String get challenge14DayHydration;
  String get challenge14DayHydrationDesc;
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
