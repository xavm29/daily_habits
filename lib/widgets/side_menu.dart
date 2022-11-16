import 'package:daily_habits/screens/profile.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';

import '../screens/challenges.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.purplelow,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Center(child: Text('1 Day')),
          ),
          Card(
            elevation: 2,
            child: ListTile(
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Profile()));
                }),
          ),
          Card(
            elevation: 2,
            child: ListTile(
                title: const Text('Chalenges'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Challenges()));
                }),
          ),
        ],
      ),
    );
  }
}
