import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  // App general
  @override
  String get appName => 'Daily Habits';
  @override
  String get home => 'Home';
  @override
  String get settings => 'Settings';
  @override
  String get profile => 'Profile';
  @override
  String get logout => 'Logout';
  @override
  String get cancel => 'Cancel';
  @override
  String get save => 'Save';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get create => 'Create';
  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get success => 'Success';
  @override
  String get confirm => 'Confirm';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';

  // Authentication
  @override
  String get welcomeBack => 'Welcome Back';
  @override
  String get signIn => 'Sign In';
  @override
  String get signUp => 'Sign Up';
  @override
  String get signInToContinue => 'Sign in to continue';
  @override
  String get signUpToSaveProgress => 'Sign up to save your progress';
  @override
  String get createAccount => 'Create Account';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get continueWithGoogle => 'Continue with Google';
  @override
  String get skipForNow => 'Skip for now';
  @override
  String get youCanRegisterLater => 'You can register later to sync your data';
  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';
  @override
  String get dontHaveAccount => "Don't have an account? Sign Up";
  @override
  String get signInButton => 'Sign In';
  @override
  String get signUpButton => 'Sign Up';
  @override
  String get or => 'OR';

  // Validation
  @override
  String get pleaseEnterEmail => 'Please enter your email';
  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';
  @override
  String get pleaseEnterPassword => 'Please enter your password';
  @override
  String get passwordMustBe6Characters => 'Password must be at least 6 characters';

  // Home Screen
  @override
  String get toBeDone => 'To be done';
  @override
  String get completed => 'Completed';
  @override
  String get noGoalsForToday => 'No goals for today';
  @override
  String get target => 'Target';
  @override
  String get track => 'Track';

  // Goals
  @override
  String get createGoal => 'Create Goal';
  @override
  String get editGoal => 'Edit Goal';
  @override
  String get goalTitle => 'Goal Title';
  @override
  String get goalDescription => 'Goal Description';
  @override
  String get goalType => 'Goal Type';
  @override
  String get checkbox => 'Checkbox';
  @override
  String get quantitative => 'Quantitative';
  @override
  String get duration => 'Duration';
  @override
  String get frequency => 'Frequency';
  @override
  String get daily => 'Daily';
  @override
  String get weekly => 'Weekly';
  @override
  String get selectDays => 'Select Days';
  @override
  String get monday => 'Monday';
  @override
  String get tuesday => 'Tuesday';
  @override
  String get wednesday => 'Wednesday';
  @override
  String get thursday => 'Thursday';
  @override
  String get friday => 'Friday';
  @override
  String get saturday => 'Saturday';
  @override
  String get sunday => 'Sunday';
  @override
  String get startDate => 'Start Date';
  @override
  String get endDate => 'End Date';
  @override
  String get targetValue => 'Target Value';
  @override
  String get unit => 'Unit';
  @override
  String get reminder => 'Reminder';
  @override
  String get noReminder => 'No Reminder';
  @override
  String get setReminder => 'Set Reminder';

  // Challenges
  @override
  String get challenges => 'Challenges';
  @override
  String get activeChallenges => 'Active';
  @override
  String get completedChallenges => 'Completed';
  @override
  String get createCustomChallenge => 'Create Custom Challenge';
  @override
  String get challengeTitle => 'Challenge Title';
  @override
  String get challengeDescription => 'Description';
  @override
  String get durationDays => 'Duration (days)';
  @override
  String get targetCount => 'Target Count';
  @override
  String get category => 'Category';
  @override
  String get joinChallenge => 'Join Challenge';
  @override
  String get leaveChallenge => 'Leave Challenge';
  @override
  String get daysLeft => 'days left';
  @override
  String get participants => 'joined';
  @override
  String get active => 'Active';

  // Categories
  @override
  String get general => 'General';
  @override
  String get consistency => 'Consistency';
  @override
  String get health => 'Health';
  @override
  String get productivity => 'Productivity';

  // Rewards
  @override
  String get rewards => 'Rewards';
  @override
  String get myCoins => 'My Coins';
  @override
  String get earnedCoins => 'Earned';
  @override
  String get spentCoins => 'Spent';
  @override
  String get availableCoins => 'Available';
  @override
  String get redeemReward => 'Redeem';
  @override
  String get cost => 'Cost';

  // Achievements
  @override
  String get achievements => 'Achievements';
  @override
  String get unlocked => 'Unlocked';
  @override
  String get locked => 'Locked';
  @override
  String get progress => 'Progress';

  // Settings
  @override
  String get darkMode => 'Dark Mode';
  @override
  String get language => 'Language';
  @override
  String get notifications => 'Notifications';
  @override
  String get dataExport => 'Data Export';
  @override
  String get exportData => 'Export Data';
  @override
  String get importData => 'Import Data';
  @override
  String get syncData => 'Sync Data';
  @override
  String get about => 'About';
  @override
  String get version => 'Version';
  @override
  String get privacyPolicy => 'Privacy Policy';
  @override
  String get termsOfService => 'Terms of Service';

  // Notifications
  @override
  String get notificationTitle => 'Daily Habits Reminder';
  @override
  String get notificationBody => "Don't forget to complete your habits today!";
  @override
  String get reminderNotification => 'Time to complete your habit!';

  // Social
  @override
  String get friends => 'Friends';
  @override
  String get addFriend => 'Add Friend';
  @override
  String get sendFriendRequest => 'Send Friend Request';
  @override
  String get acceptFriendRequest => 'Accept';
  @override
  String get friendRequests => 'Friend Requests';
  @override
  String get compareProgress => 'Compare Progress';

  // Statistics
  @override
  String get statistics => 'Statistics';
  @override
  String get currentStreak => 'Current Streak';
  @override
  String get longestStreak => 'Longest Streak';
  @override
  String get totalCompleted => 'Total Completed';
  @override
  String get completionRate => 'Completion Rate';
  @override
  String get thisWeek => 'This Week';
  @override
  String get thisMonth => 'This Month';
  @override
  String get allTime => 'All Time';

  // Messages
  @override
  String get greatJob => 'Great job!';
  @override
  String get keepItUp => 'Keep it up!';
  @override
  String get perfectDay => 'Perfect Day!';
  @override
  String get taskCompleted => 'Task Completed';
  @override
  String get goalAchieved => 'Goal Achieved!';
  @override
  String get challengeJoined => 'Joined challenge successfully!';
  @override
  String get challengeCompleted => 'Challenge Completed!';
  @override
  String get rewardRedeemed => 'Reward Redeemed!';
  @override
  String get dataExported => 'Data exported successfully';
  @override
  String get dataImported => 'Data imported successfully';
  @override
  String get friendRequestSent => 'Friend request sent';
  @override
  String get friendRequestAccepted => 'Friend request accepted';

  // Errors
  @override
  String get errorLoadingData => 'Error loading data';
  @override
  String get errorSavingData => 'Error saving data';
  @override
  String get errorDeletingData => 'Error deleting data';
  @override
  String get errorSigningIn => 'Error signing in';
  @override
  String get errorSigningUp => 'Error signing up';
  @override
  String get errorSigningOut => 'Error signing out';
  @override
  String get errorNetwork => 'Network error. Please check your connection.';
  @override
  String get errorUnknown => 'An unknown error occurred';

  // Prompts
  @override
  String get deleteGoalPrompt => 'Are you sure you want to delete this goal?';
  @override
  String get deleteChallengePrompt => 'Are you sure you want to delete this challenge?';
  @override
  String get leaveAppPrompt => 'Are you sure you want to exit?';
  @override
  String get signOutPrompt => 'Are you sure you want to sign out?';

  // Onboarding
  @override
  String get welcomeToApp => 'Welcome to Daily Habits!';
  @override
  String get onboardingTitle1 => 'Track Your Habits';
  @override
  String get onboardingBody1 => 'Create and track your daily habits to build a better you';
  @override
  String get onboardingTitle2 => 'Join Challenges';
  @override
  String get onboardingBody2 => 'Participate in challenges to stay motivated';
  @override
  String get onboardingTitle3 => 'Earn Rewards';
  @override
  String get onboardingBody3 => 'Complete tasks and earn coins to redeem rewards';
  @override
  String get getStarted => 'Get Started';
  @override
  String get skip => 'Skip';
  @override
  String get next => 'Next';
  @override
  String get back => 'Back';
}
