import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:daily_habits/models/completed_goal.dart';
import 'package:daily_habits/models/goals_model.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/reward_service.dart';
import '../services/local_storage_service.dart';
import '../services/review_service.dart';
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

    // Check for registration prompt
    _checkRegistrationPrompt();

    // Check for review prompt
    _checkReviewPrompt();
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

      // Show success message with coins
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Great job! +$coinsEarned coins 🎉'),
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

          // Calculate coins earned
          int currentStreak = _getCurrentStreak();
          bool isPerfectDay = _isPerfectDay();
          int coinsEarned = RewardService.instance.calculateCoinsForTask(isPerfectDay, currentStreak);

          // Add coins to user
          await RewardService.instance.addCoins(coinsEarned, reason: 'Completed: ${goals[key]!.title}');

          // Show success message with achieved value and coins
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Completed: $value ${goals[key]!.unit ?? ""}! +$coinsEarned coins 🎉'),
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

  Future<void> _checkRegistrationPrompt() async {
    // Only check if user is not signed in
    if (FirebaseService.instance.user != null) return;

    // Check if we should prompt for registration
    final shouldPrompt = await LocalStorageService.instance.shouldPromptForRegistration();

    if (shouldPrompt && mounted) {
      // Wait a bit before showing the dialog
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RegistrationPromptDialog(
          onRegister: () {
            Navigator.pop(context);
            // Navigate to login screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginCustomScreen()),
            );
          },
          onLater: () {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("To be done", style: TextStyles.bigText),
          ),
          Expanded(
            child: ListView(
              children: [
                for (var key in goals.keys)
                  if (!goals[key]!.isCompletedForDate(dateSelected, userData) &&
                      goals[key]!.isVisible(dateSelected))
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                          child: ListTile(
                        title: Text(goals[key]!.title),
                        subtitle: goals[key]!.goalType != Goal.kTypeCheckbox
                            ? Text('Target: ${goals[key]!.targetValue} ${goals[key]!.unit ?? ""}')
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
                                label: const Text('Track'),
                                onPressed: () {
                                  _showQuantitativeDialog(key);
                                },
                              ),
                      )),
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
