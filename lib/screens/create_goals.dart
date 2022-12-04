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
          title: Text('Create Goals'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                  width: double.infinity,
                  height: 320,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/Vectorfondo.png"),
                          fit: BoxFit.fill)),
                  child: Image.asset("assets/images/person.png")),
              SizedBox(
                height: 300,
                child: Row(
                  children: [
                    Text("Set your Goals"),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextField(
                      decoration: InputDecoration(
                    labelText: 'Nº',
                  )),
                  TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Goal',
                      ))
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
              Text("Repeat everyday "),
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
