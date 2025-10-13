import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';
import '../providers/theme_provider.dart';
import '../services/firebase_service.dart';
import '../services/analytics_service.dart';
import '../styles/styles.dart';
import '../utils/dialogs.dart';
import 'login_custom.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primarys,
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Consumer<UserData>(builder: (context, userData, child) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: InkWell(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              // Pick an image
                              image = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (image != null) {
                                FirebaseService.instance.updatePhoto(image!);
                              }
                              setState(() {});
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: image != null
                                  ? FileImage(File(image!.path))
                                  : FirebaseService.instance.user!.photoURL != null
                                      ? NetworkImage(FirebaseService.instance.user!.photoURL!)
                                      : const AssetImage('assets/images/icon.png') as ImageProvider,
                            ),
                          ),
                        );
                      }),
                      Consumer<UserData>(builder: (context, userData, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(FirebaseService.instance.user?.displayName ??
                                " --- "),
                            const Text("Name"),
                            InkWell(
                                onTap: () async {
                                  String? nameEntered =
                                  await inputDialog(context, "Your name");
                                  if (nameEntered != null) {
                                    if (!mounted) return;
                                    userData.setUserName(nameEntered);
                                  }
                                },
                                child: const Icon(Icons.edit))
                          ],
                        );
                      }),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text("this week"),
                    ],
                  ),
                  const Divider(
                    height: 20,
                    thickness: 2,
                    indent: 10,
                    endIndent: 10,
                    color: Colors.black,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Total hours"),
                              Text("18", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        const Expanded(flex: 1, child: Icon(Icons.access_time)),
                        const SizedBox(
                            height: 45,
                            child: VerticalDivider(
                              thickness: 2,
                              width: 20,
                              color: Colors.black,
                            )),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Completed"),
                              Text("12", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        const Expanded(flex: 1, child: Icon(Icons.check_circle)),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 20,
                    thickness: 2,
                    indent: 10,
                    endIndent: 10,
                    color: Colors.black,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 20.0,
                        lineWidth: 5.0,
                        percent: 1.0,
                        progressColor: Colors.green,
                      ),
                      CircularPercentIndicator(
                        radius: 20.0,
                        lineWidth: 5.0,
                        percent: 1.0,
                        progressColor: Colors.green,
                      ),
                      CircularPercentIndicator(
                        radius: 20.0,
                        lineWidth: 5.0,
                        percent: 1.0,
                        progressColor: Colors.green,
                      ),
                      CircularPercentIndicator(
                        radius: 20.0,
                        lineWidth: 5.0,
                        percent: 1.0,
                        progressColor: Colors.green,
                      ),
                      CircularPercentIndicator(
                        radius: 20.0,
                        lineWidth: 5.0,
                        percent: 1.0,
                        progressColor: Colors.green,
                      ),
                      CircularPercentIndicator(
                        radius: 20.0,
                        lineWidth: 5.0,
                        percent: 1.0,
                        progressColor: Colors.green,
                      ),
                      CircularPercentIndicator(
                        radius: 20.0,
                        lineWidth: 5.0,
                        percent: 1.0,
                        progressColor: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time),
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Current streak"),
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("20 days"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Switch between light and dark theme'),
                    secondary: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primarys,
                    ),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: AppColors.primarys,
                  );
                },
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                // Track logout
                await AnalyticsService.instance.logLogout();

                // Sign out from Firebase
                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                // Navigate to login screen
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginCustomScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text(
                'Log out',
                style: TextStyles.label,
              ))
        ]
        )
    );
  }
}
