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
    final ButtonStyle style2 =
        ElevatedButton.styleFrom(primary: Colors.white, onPrimary: Colors.black)
            .copyWith(elevation: ButtonStyleButton.allOrNull(2.0));
    const List<Widget> Days = <Widget>[
      Text('S'),
      Text('M'),
      Text('T'),
      Text('W'),
      Text('T'),
      Text('F'),
      Text('S'),
    ];
    final List<bool> _selecteddays = <bool>[
      true,
      false,
      false,
      true,
      true,
      true,
      true
    ];
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const [
                    Text(
                      "Set your Goals",
                      style: TextStyles.title,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
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
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
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
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "Repeat everyday ",
                  style: TextStyles.title,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(22))),
                      child: ToggleButtons(
                        direction: Axis.horizontal,
                        onPressed: (int index) {
                          setState(() {
                            // The button that is tapped is set to true, and the others to false.
                            for (int i = 0; i < _selecteddays.length; i++) {
                              _selecteddays[i] = i == index;
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

                        children: Days,
                        isSelected: _selecteddays,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {},
                    child: Text("Set end date"),
                    style: style2),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {}, child: Text("Continue"), style: (style2)),
              )
            ],
          ),
        ));
  }
}
