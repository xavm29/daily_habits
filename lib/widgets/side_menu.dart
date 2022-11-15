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
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Center(child: Text('1 Day')),
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
