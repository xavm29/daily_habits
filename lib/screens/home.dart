import 'package:daily_habits/models/completed_goal.dart';
import 'package:daily_habits/models/goals_model.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_calendar/horizontal_calendar.dart';
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

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    dateSelected = DateTime.parse("${now.year}-${now.month}-${now.day}");
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
        title: Text('home'),
      ),
      drawer: const SideMenu(),
      body: Column(
        children: [
          HorizontalCalendar(
              date: dateSelected,
              onDateSelected: (var date) {
                dateSelected = DateTime.parse(date);
                setState(() {});
                print(date.toString());
              }),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("To be done", style: TextStyles.bigText),
          ),
          for (var key in goals.keys)
            if (!goals[key]!.isCompletedForDate(dateSelected, userData) &&
                !goals[key]!.isVisible(dateSelected))
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                    child: ListTile(
                  title: Text(goals[key]!.title),
                  leading: FlutterLogo(),
                  trailing: Checkbox(
                    value:
                        goals[key]!.isCompletedForDate(dateSelected, userData),
                    onChanged: (bool? value) async {
                      var task = CompletedTask(key, dateSelected);
                      userData.tasks.add(task);
                      await FirebaseService.instance.saveCompletedGoals(task);
                      setState(() {});
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
