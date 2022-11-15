import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../widgets/side_menu.dart';

class Challenges extends StatefulWidget {
  const Challenges({Key? key}) : super(key: key);

  @override
  State<Challenges> createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenges'),
      ),
      drawer: const SideMenu(),
      body: Column(
        children: [
          Card(
            child: Expanded(
              child: ListTile(
                  title: Expanded(child: Text('Three-line ListTile')),
                  subtitle:
                      Expanded(child: Text('A sufficiently long subtitle warrants three lines.')),
                  leading: Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                      onPressed: () => {},
                      child: const Text('Filled'),
                    ),
                  ),
                  trailing: Expanded(
                    child: CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 5.0,
                      percent: 1.0,
                      center: new Text("100%"),
                      progressColor: Colors.green,
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
