import 'package:flutter/material.dart';

import '../styles/styles.dart';

class CreateGoals extends StatefulWidget {
  const CreateGoals({Key? key}) : super(key: key);

  @override
  State<CreateGoals> createState() => _CreateGoalsState();
}

class _CreateGoalsState extends State<CreateGoals> {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
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
                          image: AssetImage("assets/images/Vectorfondo.png"),
                          fit: BoxFit.fill)),
                  child: Align(
                    child: Image.asset("assets/images/person.png"),
                    alignment: Alignment.bottomCenter,
                  )),
              Row(
                children: const [
                  Text("Set your Goals"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Flexible(
                    child: TextField(
                        decoration: InputDecoration(
                            filled: true,
                            labelText: 'Nº',
                            fillColor: Colors.white)),
                  ),
                  Flexible(
                    child: TextField(
                        decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Goal',
                    )),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {}, child: Text("Daily"), style: style),
                  ElevatedButton(
                      onPressed: () {}, child: Text("Wekly"), style: style),
                  ElevatedButton(
                      onPressed: () {}, child: Text("Montly"), style: style)
                ],
              ),
              const Text("Repeat everyday "),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                      onPressed: () {}, child: Text("S"), style: style),
                  ElevatedButton(
                      onPressed: () {}, child: Text("M"), style: style),
                  ElevatedButton(
                      onPressed: () {}, child: Text("T"), style: style)
                ],
              ),
              ElevatedButton(
                  onPressed: () {}, child: Text("Continue"), style: style)
            ],
          ),
        ));
  }
}
