import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:daily_habits/models/completed_goal.dart';
import 'package:daily_habits/models/goals_model.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../models/user_data.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/reward_service.dart';
import '../services/local_storage_service.dart';
import '../services/review_service.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/challenge_service.dart';
import '../widgets/side_menu.dart';
import '../widgets/quantitative_dialog.dart';
import '../widgets/registration_prompt_dialog.dart';
import '../widgets/review_prompt_dialog.dart';
import 'create_goals.dart';
import 'login_custom.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  var goals = <String, Goal>{};
  late UserData userData;
  late DateTime dateSelected;
  late DateTime focusedDay;
  CalendarFormat calendarFormat = CalendarFormat.week;
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  bool _showCompletedHabits = true;
  bool _showProgressBar = true;
  int _weekStartDay = 1; // 1 = Monday, 0 = Sunday
  String _dateFormat = 'dd/MM/yyyy';

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    dateSelected = DateTime(now.year, now.month, now.day);
    focusedDay = dateSelected;
    var stream = FirebaseService.instance.goalsStream;
    userData = Provider.of<UserData>(context, listen: false);

    // Initialize confetti controller
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize notification service
    NotificationService().initialize();

    stream.listen((event) {
      goals.clear();
      for (var doc in event.docs) {
        var goal = Goal.fromJson(doc.data());
        goal.id = doc.id;
        goals[doc.id] = goal;
      }
      setState(() {});
    });

    // Load settings
    _loadSettings();

    // Check for registration prompt
    _checkRegistrationPrompt();

    // Check for review prompt
    _checkReviewPrompt();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showCompletedHabits = prefs.getBool('show_completed') ?? true;
      _showProgressBar = prefs.getBool('show_progress') ?? true;
      _weekStartDay = prefs.getInt('week_start_day') ?? 1;
      _dateFormat = prefs.getString('date_format') ?? 'dd/MM/yyyy';
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckboxCompletion(String key, bool? value) async {
    if (value == true) {
      // Play confetti animation
      _confettiController.play();

      // Play sound and vibration
      await SoundService.instance.playSuccessSound();
      await VibrationService.instance.vibrateSuccess();

      // Animate checkbox
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Calculate coins earned
      int currentStreak = _getCurrentStreak();
      bool isPerfectDay = _isPerfectDay();
      int coinsEarned = RewardService.instance.calculateCoinsForTask(isPerfectDay, currentStreak);

      // Add coins to user
      await RewardService.instance.addCoins(coinsEarned, reason: 'Completed: ${goals[key]!.title}');

      // Track analytics
      try {
        await AnalyticsService.instance.logCompleteTask(
          goalId: key,
          goalTitle: goals[key]!.title,
          streak: currentStreak,
          isPerfectDay: isPerfectDay,
        );
        await AnalyticsService.instance.logEarnCoins(
          amount: coinsEarned,
          reason: 'Completed: ${goals[key]!.title}',
        );
      } catch (e, stackTrace) {
        await CrashlyticsService.instance.recordError(e, stackTrace, reason: 'Failed to track task completion analytics');
      }

      // Show success message with coins
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.greatJobCoins(coinsEarned)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    var task = CompletedTask(key, dateSelected);
    userData.tasks.add(task);
    await FirebaseService.instance.saveCompletedGoals(task);

    // Update challenge progress if this habit is part of a challenge
    try {
      await ChallengeService.instance.checkAndUpdateChallengesOnHabitCompletion(
        goalTitle: goals[key]!.title,
        goalCategory: goals[key]!.category,
      );
    } catch (e, stackTrace) {
      await CrashlyticsService.instance.recordError(e, stackTrace, reason: 'Failed to update challenge progress');
    }

    setState(() {});
  }

  void _showQuantitativeDialog(String key) {
    showDialog(
      context: context,
      builder: (context) => QuantitativeDialog(
        goal: goals[key]!,
        onComplete: (value, notes, mood) async {
          // Play confetti animation
          _confettiController.play();

          // Play sound and vibration
          await SoundService.instance.playSuccessSound();
          await VibrationService.instance.vibrateSuccess();

          // Calculate coins earned
          int currentStreak = _getCurrentStreak();
          bool isPerfectDay = _isPerfectDay();
          int coinsEarned = RewardService.instance.calculateCoinsForTask(isPerfectDay, currentStreak);

          // Add coins to user
          await RewardService.instance.addCoins(coinsEarned, reason: 'Completed: ${goals[key]!.title}');

          // Track analytics
          try {
            await AnalyticsService.instance.logCompleteTask(
              goalId: key,
              goalTitle: goals[key]!.title,
              streak: currentStreak,
              isPerfectDay: isPerfectDay,
            );
            await AnalyticsService.instance.logEarnCoins(
              amount: coinsEarned,
              reason: 'Completed: ${goals[key]!.title}',
            );
          } catch (e, stackTrace) {
            await CrashlyticsService.instance.recordError(e, stackTrace, reason: 'Failed to track quantitative task analytics');
          }

          // Show success message with achieved value and coins
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(l10n.completedWithCoins(value.toString(), goals[key]!.unit ?? "", coinsEarned)),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          var task = CompletedTask(
            key,
            dateSelected,
            achievedValue: value,
            notes: notes,
            mood: mood,
          );
          userData.tasks.add(task);
          await FirebaseService.instance.saveCompletedGoals(task);

          // Update challenge progress if this habit is part of a challenge
          try {
            await ChallengeService.instance.checkAndUpdateChallengesOnHabitCompletion(
              goalTitle: goals[key]!.title,
              goalCategory: goals[key]!.category,
            );
          } catch (e, stackTrace) {
            await CrashlyticsService.instance.recordError(e, stackTrace, reason: 'Failed to update challenge progress');
          }

          setState(() {});
        },
      ),
    );
  }

  int _getCurrentStreak() {
    if (userData.tasks.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      bool hasTaskForDay = userData.tasks.any((task) {
        DateTime taskDate = DateTime(
          task.completedDateTime.year,
          task.completedDateTime.month,
          task.completedDateTime.day,
        );
        DateTime compareDate = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
        );
        return taskDate == compareDate;
      });

      if (!hasTaskForDay) break;
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  bool _isPerfectDay() {
    if (goals.isEmpty) return false;

    int totalGoalsForToday = 0;
    int completedGoalsForToday = 0;

    for (var goal in goals.values) {
      if (goal.isVisible(dateSelected)) {
        totalGoalsForToday++;
        if (goal.isCompletedForDate(dateSelected, userData)) {
          completedGoalsForToday++;
        }
      }
    }

    return totalGoalsForToday > 0 && completedGoalsForToday == totalGoalsForToday;
  }

  double _getGoalProgress(String key) {
    final goal = goals[key];
    if (goal == null || goal.targetValue == null) return 0.0;

    // Find completed tasks for this goal on the selected date
    final completedTasks = userData.tasks.where((task) {
      final taskDate = DateTime(
        task.completedDateTime.year,
        task.completedDateTime.month,
        task.completedDateTime.day,
      );
      final selected = DateTime(
        dateSelected.year,
        dateSelected.month,
        dateSelected.day,
      );
      return task.goalId == key && taskDate == selected;
    });

    if (completedTasks.isEmpty) return 0.0;

    // Sum up achieved values
    double totalAchieved = 0.0;
    for (var task in completedTasks) {
      totalAchieved += task.achievedValue ?? 0.0;
    }

    // Calculate progress (cap at 1.0 for 100%)
    double progress = totalAchieved / goal.targetValue!;
    return progress > 1.0 ? 1.0 : progress;
  }

  Future<void> _checkRegistrationPrompt() async {
    // Only check if user is not signed in
    if (FirebaseService.instance.user != null) return;

    // Check if we should prompt for registration
    final shouldPrompt = await LocalStorageService.instance.shouldPromptForRegistration();

    if (shouldPrompt && mounted) {
      // Track that we're showing the prompt
      try {
        final prefs = await SharedPreferences.getInstance();
        final usageCount = prefs.getInt('usage_count') ?? 0;
        await AnalyticsService.instance.logShowRegistrationPrompt(usageCount: usageCount);
      } catch (e, stackTrace) {
        await CrashlyticsService.instance.recordError(e, stackTrace, reason: 'Failed to track registration prompt');
      }

      // Wait a bit before showing the dialog
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RegistrationPromptDialog(
          onRegister: () async {
            await AnalyticsService.instance.logAcceptRegistrationPrompt();
            Navigator.pop(context);
            // Navigate to login screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginCustomScreen()),
            );
          },
          onLater: () async {
            await AnalyticsService.instance.logDismissRegistrationPrompt();
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  Future<void> _checkReviewPrompt() async {
    // Check if we should request a review
    final shouldRequest = await ReviewService.instance.shouldRequestReview(
      userData.tasks.length,
    );

    if (shouldRequest && mounted) {
      // Track that we're requesting review
      await AnalyticsService.instance.logRequestReview();

      // Wait a bit before showing the dialog
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => ReviewPromptDialog(
          onReviewNow: () async {
            Navigator.pop(context);
            await ReviewService.instance.requestReview();
            await ReviewService.instance.markReviewAsCompleted();
            await AnalyticsService.instance.logRateApp(rating: 5); // Assuming they'll rate positively
          },
          onLater: () {
            Navigator.pop(context);
          },
          onNoThanks: () async {
            Navigator.pop(context);
            await ReviewService.instance.markReviewAsCompleted();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
      ),
      drawer: const SideMenu(),
      body: Stack(
        children: [
          Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(dateSelected, day),
            calendarFormat: calendarFormat,
            startingDayOfWeek: _weekStartDay == 0 ? StartingDayOfWeek.sunday : StartingDayOfWeek.monday,
            onDaySelected: (selectedDay, focused) {
              setState(() {
                dateSelected = selectedDay;
                focusedDay = focused;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                calendarFormat = format;
              });
            },
            onPageChanged: (focused) {
              focusedDay = focused;
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppColors.primarys,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primarys.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(l10n.toBeDone, style: TextStyles.bigText),
          ),
          Expanded(
            child: ListView(
              children: [
                // Debug: Show info if no pending tasks
                if (goals.isNotEmpty &&
                    !goals.keys.any((key) =>
                      !goals[key]!.isCompletedForDate(dateSelected, userData) &&
                      goals[key]!.isVisible(dateSelected)))
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          l10n.noGoalsForToday,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Total hábitos: ${goals.length}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (goals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No hay hábitos creados',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Pending habits
                for (var key in goals.keys)
                  if (!goals[key]!.isCompletedForDate(dateSelected, userData) &&
                      goals[key]!.isVisible(dateSelected))
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                          child: Column(
                            children: [
                              ListTile(
                        title: Text(goals[key]!.title),
                        subtitle: goals[key]!.goalType != Goal.kTypeCheckbox
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${l10n.target}: ${goals[key]!.targetValue} ${goals[key]!.unit ?? ""}'),
                                  if (_showProgressBar && goals[key]!.goalType != Goal.kTypeCheckbox)
                                    const SizedBox(height: 8),
                                  if (_showProgressBar && goals[key]!.goalType != Goal.kTypeCheckbox)
                                    LinearProgressIndicator(
                                      value: _getGoalProgress(key),
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primarys),
                                    ),
                                ],
                              )
                            : null,
                        leading: Icon(
                          goals[key]!.goalType == Goal.kTypeDuration
                              ? Icons.timer
                              : goals[key]!.goalType == Goal.kTypeQuantity
                                  ? Icons.numbers
                                  : Icons.flag,
                        ),
                        trailing: goals[key]!.goalType == Goal.kTypeCheckbox
                            ? ScaleTransition(
                                scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Curves.elasticOut,
                                  ),
                                ),
                                child: Checkbox(
                                  value: goals[key]!
                                      .isCompletedForDate(dateSelected, userData),
                                  onChanged: (bool? value) async {
                                    await _handleCheckboxCompletion(key, value);
                                  },
                                ),
                              )
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.add_circle, size: 18),
                                label: Text(l10n.track),
                                onPressed: () {
                                  _showQuantitativeDialog(key);
                                },
                              ),
                      ),
                            ],
                          )),
                    ),
                // Completed habits section
                if (_showCompletedHabits && goals.values.any((g) => g.isCompletedForDate(dateSelected, userData) && g.isVisible(dateSelected)))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(l10n.completed, style: TextStyles.bigText),
                  ),
                if (_showCompletedHabits)
                  for (var key in goals.keys)
                    if (goals[key]!.isCompletedForDate(dateSelected, userData) &&
                        goals[key]!.isVisible(dateSelected))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: Colors.green.withOpacity(0.1),
                          child: ListTile(
                            title: Text(
                              goals[key]!.title,
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            subtitle: goals[key]!.goalType != Goal.kTypeCheckbox
                                ? Text(
                                    '${l10n.target}: ${goals[key]!.targetValue} ${goals[key]!.unit ?? ""}',
                                    style: const TextStyle(color: Colors.grey),
                                  )
                                : null,
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            trailing: const Icon(Icons.done, color: Colors.green),
                          ),
                        ),
                      )
              ],
            ),
          )
        ],
          ),
          // Confetti widget
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: ((context) => const CreateGoals())));
          // Add your onPressed code here!
        },
        backgroundColor: AppColors.primarys,
        child: const Icon(Icons.add_circle),
      ),
    );
  }
}
