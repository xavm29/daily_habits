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
    var stream = FirebaseService.instance.tasksStream;

    stream.listen((event) {
      goals.clear();
      for (var doc in event.docs) {
        var task = Goal.fromJson(doc.data());
        goals[doc.id] = task;
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                child: ListTile(
              title: Text("hola"),
              leading: FlutterLogo(),
              trailing: Checkbox(
                value: true,
                onChanged: (bool? value) {},
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
