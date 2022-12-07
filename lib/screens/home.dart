import 'package:daily_habits/screens/challenges.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';

import '../widgets/side_menu.dart';
import 'create_goals.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('home'),),
      drawer: const SideMenu(),
      body: Column(

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: ((context) =>const CreateGoals() )));
          // Add your onPressed code here!
        },
        backgroundColor:AppColors.primarys,
        child: const Icon(Icons.add_circle),
      ),
    );
  }
}

