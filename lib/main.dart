import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
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
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice bluetoothDevice;
  BluetoothService bluetoothService;
  BluetoothCharacteristic bluetoothCharacteristic;
  List<int> readValues = [];
  dynamic ax, ay, az, ox, oy, oz, mx, my, mz;

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
    print(dir.toString());
    switch (dir) {
      case MoveDirection.moveToLeft:
        if (curPositionId == 2 || curPositionId == 4)
          setState(() {
            curPositionId--;
          });
        break;
      case MoveDirection.moveToRight:
        if (curPositionId == 1 || curPositionId == 3)
          setState(() {
            curPositionId++;
          });
        break;
      case MoveDirection.moveForward:
        if (curPositionId == 3 || curPositionId == 4)
          setState(() {
            curPositionId -= 2;
          });
        break;
      case MoveDirection.moveBackward:
        if (curPositionId == 1 || curPositionId == 2)
          setState(() {
            curPositionId += 2;
          });
        break;
    }
  }

  void connectToDevice() {
    flutterBlue
        .startScan(
      timeout: Duration(seconds: 3),
    )
        .then((results) async {
      for (ScanResult r in results) {
        if (r.device.name.contains("NAXSEN")) {
          print("device found");
          await r.device.connect();
          return r.device;
        } else {
          print("device not found");
        }
      }
      return null;
    }).then((device) async {
      if (device == null) {
        return null;
      } else {
        setState(() {
          bluetoothDevice = device;
        });
        await bluetoothDevice.discoverServices().then((services) async {
          for (BluetoothService s in services) {
            if (s.uuid.toString().toUpperCase().substring(4, 8) == "1600") {
              print("service 1600 found");
              setState(() {
                bluetoothService = s;
                bluetoothCharacteristic =
                    bluetoothService.characteristics.firstWhere((c) {
                  return c.uuid.toString().contains("1601");
                });
              });

              bluetoothCharacteristic.value.listen((value) {
                mx = value[0] * 256 + value[1];
                if (mx > 32768) mx = mx - 65536;
                mx = mx / 32768;
                if (mx > 0.2) playerMove(MoveDirection.moveToRight);
                if (mx < -0.2) playerMove(MoveDirection.moveToLeft);
                print("${curPositionId}");
                setState(() {
                  readValues = value;
                  mx = mx;
                });
              });
              await bluetoothCharacteristic.setNotifyValue(true);
            }
          }
        });
      }
    });
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
                      onPressed: (() {
                        flutterBlue.connectedDevices.then((devices) {
                          for (BluetoothDevice d in devices) d.disconnect();
                        });
                      }),
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
                  height: 80,
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
                Text(
                  readValues.toString(),
                ),
                Text("加速度：x${mx}"),
                // children: bluetoothService.characteristics.map((c) {
                //   return StreamBuilder<List<int>>(
                //       initialData: [],
                //       stream: c.value,
                //       builder: (context, snapshot) {
                //         return Text(c.uuid.toString().substring(4, 8));
                //       });
                // }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
