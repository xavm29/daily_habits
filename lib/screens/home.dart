import 'package:daily_habits/models/completed_goal.dart';
import 'package:daily_habits/models/goals_model.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';
import '../services/firebase_service.dart';
import '../widgets/side_menu.dart';
import 'create_goals.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var goals = <String, Goal>{};
  late UserData userData;
  late DateTime dateSelected;
  late DateTime focusedDay;
  CalendarFormat calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    dateSelected = DateTime(now.year, now.month, now.day);
    focusedDay = dateSelected;
    var stream = FirebaseService.instance.goalsStream;
    userData = Provider.of<UserData>(context, listen: false);

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: const SideMenu(),
      body: Column(
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
                        trailing: Checkbox(
                          value: goals[key]!
                              .isCompletedForDate(dateSelected, userData),
                          onChanged: (bool? value) async {
                            var task = CompletedTask(key, dateSelected);
                            userData.tasks.add(task);
                            await FirebaseService.instance
                                .saveCompletedGoals(task);
                            setState(() {});
                          },
                        ),
                      )),
                    )
              ],
            ),
          )
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
