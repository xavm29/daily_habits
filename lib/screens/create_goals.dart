import 'package:daily_habits/services/firebase_service.dart';
import 'package:daily_habits/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/goals_model.dart';
import '../styles/styles.dart';

class CreateGoals extends StatefulWidget {
  final String? goalId;
  final Goal? existingGoal;

  const CreateGoals({Key? key, this.goalId, this.existingGoal}) : super(key: key);

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

    // Load existing goal data if editing
    if (widget.existingGoal != null) {
      final goal = widget.existingGoal!;
      goalTextController.text = goal.title;
      endDate = goal.endDate;
      hourReminder = goal.hourReminder;
      periodic = goal.periodic;
      goalType = goal.goalType;
      weekDays.addAll(goal.weekDays);

      if (goal.targetValue != null) {
        targetValueController.text = goal.targetValue.toString();
      }
      if (goal.unit != null) {
        unitController.text = goal.unit!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
        backgroundColor: AppColors.primarys,
        appBar: AppBar(
          title: Text(widget.goalId != null ? l10n.editGoal : l10n.createGoal),
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
                  children: [
                    Text(
                      l10n.setYourGoals,
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
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: l10n.goal,
                        ),
                        controller: goalTextController,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  l10n.goalType,
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
                        child: Text(l10n.checkbox)),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            goalType = Goal.kTypeQuantity;
                          });
                        },
                        style: goalType == Goal.kTypeQuantity
                            ? styleSelected
                            : styleUnselected,
                        child: Text(l10n.quantity)),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            goalType = Goal.kTypeDuration;
                          });
                        },
                        style: goalType == Goal.kTypeDuration
                            ? styleSelected
                            : styleUnselected,
                        child: Text(l10n.duration)),
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
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: l10n.targetValue,
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
                            labelText: goalType == Goal.kTypeDuration ? l10n.unitMin : l10n.unit,
                          ),
                          controller: unitController,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  l10n.frequency,
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
                        child: Text(l10n.daily)),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            periodic = Goal.kWeekly;
                          });
                        },
                        style: periodic == Goal.kWeekly
                            ? styleSelected
                            : styleUnselected,
                        child: Text(l10n.weekly)),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            periodic = Goal.kMonthly;
                          });
                        },
                        style: periodic == Goal.kMonthly
                            ? styleSelected
                            : styleUnselected,
                        child: Text(l10n.monthly))
                  ],
                ),
              ),
              if (periodic == Goal.kWeekly)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    l10n.repeatEveryDay,
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
                        : Text(l10n.selectYourTimeReminder),
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
                        : Text(l10n.selectYourEndDate),
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
                          SnackBar(content: Text(l10n.pleaseEnterGoal)),
                        );
                        return;
                      }
                      if (endDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pleaseSelectEndDate)),
                        );
                        return;
                      }
                      if (hourReminder == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pleaseSelectReminderTime)),
                        );
                        return;
                      }
                      double? targetValue;
                      String? unit;

                      if (goalType != Goal.kTypeCheckbox) {
                        if (targetValueController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.pleaseEnterTargetValue)),
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

                      // Check if we're editing or creating
                      if (widget.goalId != null) {
                        await FirebaseService.instance.updateGoal(widget.goalId!, goal);
                      } else {
                        await FirebaseService.instance.saveGoal(goal);
                      }

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
                        SnackBar(
                          content: Text(widget.goalId != null ? l10n.goalUpdatedSuccessfully : l10n.goalCreatedWithReminder),
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
                    label: Text(l10n.save)),
              )
            ], // prueba de deveolop
          ),
        ));
  }
}
