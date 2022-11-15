import 'package:daily_habits/screens/challenges.dart';
import 'package:flutter/material.dart';

import '../widgets/side_menu.dart';

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
    );
  }
}

