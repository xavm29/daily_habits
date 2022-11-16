import 'package:flutter/material.dart';

import '../styles/styles.dart';
import '../widgets/side_menu.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primarys,
        appBar: AppBar(
          title: Text('Profile'),
        ),
        drawer: const SideMenu(),
        body: Column(children: [
          Card(
            elevation: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      NetworkImage('https://picsum.photos/id/237/200/300'),
                ),
                Text('Name'),
              ],
            ),
          ),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Total horus'),
                  Text('18'),
                  Icon(Icons.ice_skating_outlined)
                ],
              )
            ],
          )
        ]));
  }
}
