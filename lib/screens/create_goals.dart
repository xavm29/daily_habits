import 'package:daily_habits/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import '../models/goals_model.dart';
import '../styles/styles.dart';

class CreateGoals extends StatefulWidget {
  const CreateGoals({Key? key}) : super(key: key);

  @override
  State<CreateGoals> createState() => _CreateGoalsState();
}

class _CreateGoalsState extends State<CreateGoals> {
  int? number;
  DateTime? endDate;
  DateTime? hourReminder;
  late TextEditingController goalTextController;
  late TextEditingController numberTextController;
  int periodic = 0;
  final List<int> weekDays = [];

  final ButtonStyle styleSelected = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), backgroundColor: Colors.orange);
  final ButtonStyle styleUnselected =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  static const List<Widget> days = <Widget>[
    Text('M'),
    Text('T'),
    Text('W'),
    Text('T'),
    Text('F'),
    Text('S'),
    Text('S'),
  ];

  @override
  void initState() {
    super.initState();
    goalTextController = TextEditingController();
    numberTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primarys,
        appBar: AppBar(
          title: const Text('Create Goals'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  height: 320,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image:
                              AssetImage("assets/images/vector-background.png"),
                          fit: BoxFit.fill)),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset("assets/images/person.png"),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const [
                    Text(
                      "Set your Goals",
                      style: TextStyles.title,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Goal',
                        ),
                        controller: goalTextController,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            periodic = Goal.kDaily;
                          });
                        },
                        style: periodic == Goal.kDaily
                            ? styleSelected
                            : styleUnselected,
                        child: const Text("Daily")),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            periodic = Goal.kWeekly;
                          });
                        },
                        style: periodic == Goal.kWeekly
                            ? styleSelected
                            : styleUnselected,
                        child: const Text("Weekly")),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            periodic = Goal.kMonthly;
                          });
                        },
                        style: periodic == Goal.kMonthly
                            ? styleSelected
                            : styleUnselected,
                        child: const Text("Montly"))
                  ],
                ),
              ),
              if (periodic == Goal.kWeekly)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Repeat everyday ",
                    style: TextStyles.title,
                  ),
                ),
              if (periodic == Goal.kWeekly)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(22))),
                        child: ToggleButtons(
                          direction: Axis.horizontal,
                          onPressed: (int index) {
                            setState(() {
                              if (weekDays.contains(index + 1)) {
                                weekDays.remove(index + 1);
                              } else {
                                weekDays.add(index + 1);
                              }
                            });
                          },
                          borderRadius:
                              const BorderRadius.all(Radius.circular(22)),
                          selectedBorderColor: Colors.black,
                          selectedColor: Colors.white,
                          //disabledColor:Colors.white,
                          fillColor: AppColors.purplelow,
                          color: Colors.black,
                          constraints: const BoxConstraints(
                            minHeight: 50.0,
                            minWidth: 50.0,
                          ),
                          isSelected: [
                            weekDays.contains(1),
                            weekDays.contains(2),
                            weekDays.contains(3),
                            weekDays.contains(4),
                            weekDays.contains(5),
                            weekDays.contains(6),
                            weekDays.contains(7),
                          ],

                          children: days,
                        ),
                      )
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.timer),
                    onTap: () {
                      DatePicker.showTimePicker(context, showTitleActions: true,
                          onConfirm: (hour) {
                        setState(
                          () {
                            hourReminder = hour;

                            print(hourReminder);
                          },
                        );
                      }, currentTime: DateTime.now());
                    },
                    title: (hourReminder != null)
                        ? Text(DateFormat('kk:mm').format(hourReminder!))
                        : const Text('Select your time reminder'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  color: Colors.white,
                  child: ListTile(
                    onTap: () {
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          maxTime: DateTime(2028, 6, 7), onConfirm: (date) {
                        endDate = date;
                        print(endDate);
                        setState(() {});
                      }, currentTime: DateTime.now(), locale: LocaleType.es);
                    },
                    title: (endDate != null)
                        ? Text(DateFormat('yyyy-MM-dd').format(endDate!))
                        : const Text('Select your end date'),
                    leading: const Icon(Icons.calendar_month),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    onPressed: () async {
                      await FirebaseService.instance.saveGoal(Goal(
                          goalTextController.text,
                          "",
                          periodic,
                          weekDays,
                          endDate!,
                          hourReminder!));
                      if (!mounted) return;
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(160, 50),
                        shape: const StadiumBorder(),
                        primary: Colors.white,
                        onPrimary: Colors.black),
                    label: const Text("Save")),
              )
            ], // prueba de deveolop
          ),
        ));
  }
}
