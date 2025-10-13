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
import '../widgets/side_menu.dart';
import 'create_goals.dart';

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
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
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
                        leading: const Icon(Icons.flag),
                        trailing: ScaleTransition(
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
                              if (value == true) {
                                // Play confetti animation
                                _confettiController.play();

                                // Animate checkbox
                                _animationController.forward().then((_) {
                                  _animationController.reverse();
                                });

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        Icon(Icons.check_circle,
                                            color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Great job! Keep it up! 🎉'),
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
                              await FirebaseService.instance
                                  .saveCompletedGoals(task);
                              setState(() {});
                            },
                          ),
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
