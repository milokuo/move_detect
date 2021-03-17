import 'package:flutter/material.dart';
import 'constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Body(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  //0 for left up, increase clockwise
  var curPositionId = 3;
  // FlutterBlue flutterBlue = FlutterBlue.instance;

  //Widgets part:
  Widget curPositionSign = Text(
    "現在位置",
    style: TextStyle(
      fontSize: 20,
      color: Colors.white,
    ),
  );

  //Functions part:
  void playerMove(MoveDirection dir) {
    switch (dir) {
      case MoveDirection.moveToLeft:
        if (curPositionId % 2 == 0) curPositionId--;
        break;
      case MoveDirection.moveToRight:
        if (curPositionId % 2 == 1) curPositionId++;
        break;
      case MoveDirection.moveForward:
        if (curPositionId > 2) curPositionId -= 2;
        break;
      case MoveDirection.moveBackward:
        if (curPositionId < 3) curPositionId += 2;
        break;
    }
  }

  void connectToDevice() {
    // flutterBlue
    //     .startScan(
    //       timeout: Duration(seconds: 3),
    //     )
    //     .then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.15,
            vertical: screenSize.height * 0.15,
          ),
          child: Container(
            child: Column(
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: connectToDevice,
                      child: Text(
                        "連接設備",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: null,
                      child: Text(
                        "斷開設備",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 100,
                ),
                Row(
                  children: [
                    Spacer(),
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: curPositionId == 1
                                      ? Colors.black26
                                      : Colors.white),
                            ),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: curPositionId == 2
                                      ? Colors.black26
                                      : Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: curPositionId == 3
                                      ? Colors.black26
                                      : Colors.white),
                            ),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  color: curPositionId == 4
                                      ? Colors.black26
                                      : Colors.white),
                            ),
                          ],
                        )
                      ],
                    ),
                    Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
