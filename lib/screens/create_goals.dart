import 'package:daily_habits/services/firebase_service.dart';
import 'package:daily_habits/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  late TextEditingController targetValueController;
  late TextEditingController unitController;
  int periodic = 0;
  int goalType = Goal.kTypeCheckbox;
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
    targetValueController = TextEditingController();
    unitController = TextEditingController();
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
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
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
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Goal Type",
                  style: TextStyles.title,
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
                            goalType = Goal.kTypeCheckbox;
                          });
                        },
                        style: goalType == Goal.kTypeCheckbox
                            ? styleSelected
                            : styleUnselected,
                        child: const Text("Checkbox")),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            goalType = Goal.kTypeQuantity;
                          });
                        },
                        style: goalType == Goal.kTypeQuantity
                            ? styleSelected
                            : styleUnselected,
                        child: const Text("Quantity")),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            goalType = Goal.kTypeDuration;
                          });
                        },
                        style: goalType == Goal.kTypeDuration
                            ? styleSelected
                            : styleUnselected,
                        child: const Text("Duration")),
                  ],
                ),
              ),
              if (goalType != Goal.kTypeCheckbox)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Target',
                          ),
                          controller: targetValueController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: goalType == Goal.kTypeDuration ? 'Unit (min)' : 'Unit',
                          ),
                          controller: unitController,
                        ),
                      ),
                    ],
                  ),
                ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Frequency",
                  style: TextStyles.title,
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
                    "Repeat every day ",
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
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          final now = DateTime.now();
                          hourReminder = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                    title: (hourReminder != null)
                        ? Text(DateFormat('HH:mm').format(hourReminder!))
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
                    onTap: () async {
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030, 12, 31),
                        locale: const Locale('es', 'ES'),
                      );
                      if (date != null) {
                        setState(() {
                          endDate = date;
                        });
                      }
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
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      if (goalTextController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a goal')),
                        );
                        return;
                      }
                      if (endDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select an end date')),
                        );
                        return;
                      }
                      if (hourReminder == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a reminder time')),
                        );
                        return;
                      }
                      double? targetValue;
                      String? unit;

                      if (goalType != Goal.kTypeCheckbox) {
                        if (targetValueController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a target value')),
                          );
                          return;
                        }
                        targetValue = double.tryParse(targetValueController.text);
                        unit = unitController.text.isEmpty ? null : unitController.text;
                      }

                      final goal = Goal(
                          goalTextController.text,
                          "",
                          periodic,
                          weekDays,
                          endDate!,
                          hourReminder!,
                          goalType: goalType,
                          targetValue: targetValue,
                          unit: unit);

                      await FirebaseService.instance.saveGoal(goal);

                      // Schedule notification for this goal
                      final notificationService = NotificationService();
                      await notificationService.scheduleDailyNotification(
                        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        title: 'Reminder: ${goal.title}',
                        body: 'Don\'t forget to complete your habit today!',
                        hour: hourReminder!.hour,
                        minute: hourReminder!.minute,
                        payload: goalTextController.text,
                      );

                      if (!mounted) return;

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Goal created with reminder! 🎯'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(160, 50),
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black),
                    label: const Text("Save")),
              )
            ], // prueba de deveolop
          ),
        ));
  }
}
