import 'package:daily_habits/models/completed_task.dart';
import 'package:daily_habits/models/goals_model.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_calendar/horizontal_calendar.dart';

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

  @override
  void initState() {
    super.initState();
    var stream = FirebaseService.instance.goalsStream;

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
        title: Text('home'),
      ),
      drawer: const SideMenu(),
      body: Column(
        children: [
          HorizontalCalendar(
              date: DateTime.now().add(const Duration(days: 2)),
              onDateSelected: (date) => print(
                    date.toString(),
                  )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("To be done", style: TextStyles.bigText),
          ),
          for (var key in goals.keys)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  child: ListTile(
                title: Text(goals[key]!.title),
                leading: FlutterLogo(),
                trailing: Checkbox(
                  value: goals[key]!.completed,
                  onChanged: (bool? value) {
                    if (goals[key]!.completed) goals[key]!.lastCompleted;
                    FirebaseService.instance.updateGoal(key, goals[key]!);
                    FirebaseService.instance.saveCompletedTask(CompletedTask(key, DateTime.now()));
                  },
                ),
              )),
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
