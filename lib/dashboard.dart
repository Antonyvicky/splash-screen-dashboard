// ignore_for_file: unused_field

import 'dart:math';

import 'package:carmodel/constants.dart';
import 'package:carmodel/dash.dart';
import 'package:carmodel/data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'components/car_indicators.dart';
import 'components/gear_battery.dart';
import 'components/time_and_temp.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  Color cornerImageColor = red;
  Color eyeColor = eyeOpenColor;
  final DatabaseReference _indi4Reference = FirebaseDatabase.instance

      // ignore: deprecated_member_use
      .reference()
      .child('rpi_sensors')
      .child('rpi_sensors')
      .child('seatbelt');
  final DatabaseReference _indi5Reference = FirebaseDatabase.instance

      // ignore: deprecated_member_use
      .reference()
      .child('rpi_sensors')
      .child('rpi_sensors')
      .child('ear');
  final DatabaseReference _indi6Reference = FirebaseDatabase.instance

      // ignore: deprecated_member_use
      .reference()
      .child('rpi_sensors')
      .child('rpi_sensors')
      .child('steering');
  final DatabaseReference _batteryReference = FirebaseDatabase.instance

      // ignore: deprecated_member_use
      .reference()
      .child('BATTERY LEVEL');
  final DatabaseReference _cornerReference = FirebaseDatabase.instance

      // ignore: deprecated_member_use
      .reference()
      .child('rpi_sensors')
      .child('rpi_sensors')
      .child('cornering');
  final DatabaseReference _hornReference = FirebaseDatabase.instance

      // ignore: deprecated_member_use
      .reference()
      .child('rpi_sensors')
      .child('rpi_sensors')
      .child('horn');
  final DatabaseReference _suddenReference = FirebaseDatabase.instance

      // ignore: deprecated_member_use
      .reference()
      .child('rpi_sensors')
      .child('rpi_sensors')
      .child('sudden break');

  final DatabaseReference _sterringReference = FirebaseDatabase.instance

      // ignore: deprecated_member_use
      .reference()
      .child('STEERING POSITION');
  late bool _seatbeltindicator;
  late double eyevalue;
  late bool _steeringindicator;
  late String eyeImageAssetPath;
  late String cornerImageAssetPath;
  late double battery;
  late bool batteryindicator;
  late double batteryp;
  late int cornerindicator;
  late bool hornindicator;
  late bool suddenbrake;
  late int sterringPosition;
  late Animation<double> animation;
  late AnimationController controller;
  double pastAngle = 0;
  @override
  void initState() {
    super.initState();
    _seatbeltindicator = false;
    battery = 0.0;
    batteryp = 0.0;
    eyevalue = 0.0;
    _steeringindicator = false;
    cornerindicator = 0;
    cornerImageAssetPath = "assets/cornering.png";
    hornindicator = false;
    suddenbrake = false;
    eyeImageAssetPath = "assets/eye2.png";
    sterringPosition = 0;
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    animation = Tween<double>(begin: 0, end: 0).animate(controller);

    _indi4Reference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          int seatbelvalue = event.snapshot.value as int;
          _seatbeltindicator = seatbelvalue == 1;
        });
      }
    });
    _indi5Reference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          eyevalue = event.snapshot.value as double;
          _updateEyeImageAsset();
        });
      }
    });
    _batteryReference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          battery = event.snapshot.value as double;
          batteryp = battery * 100 / 16;
        });
      }
    });
    _hornReference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          int horn = event.snapshot.value as int;
          hornindicator = horn == 1;
        });
      }
    });
    _suddenReference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          int break1 = event.snapshot.value as int;
          suddenbrake = break1 == 1;
        });
      }
    });
    _cornerReference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          cornerindicator = event.snapshot.value as int;
          _updateCornerImageAsset();
        });
      }
    });
    _sterringReference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          sterringPosition = event.snapshot.value as int;
          animation =
              Tween<double>(begin: pastAngle, end: sterringPosition * pi / 180)
                  .animate(controller);
          controller.forward(from: 0);
          pastAngle = sterringPosition * pi / 180;
        });
      }
    });
    _indi6Reference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          int steeringvalue = event.snapshot.value as int;
          _steeringindicator = steeringvalue == 1;
        });
      }
    });
  }

  Future<void> _updateCornerImageAsset() async {
    cornerImageAssetPath = await _getCornerImageAsset();
  }

  Future<String> _getCornerImageAsset() async {
    if (cornerindicator == 0) {
      cornerImageColor = green;
      return "assets/cornering.png";
    } else if (cornerindicator == 1) {
      cornerImageColor = red;
      return "assets/cornering-left.png";
    } else {
      cornerImageColor = red;
      return "assets/cornering-right.png";
    }
  }

  Future<void> _updateEyeImageAsset() async {
    eyeImageAssetPath = await _getEyeImageAsset();
  }

  Future<String> _getEyeImageAsset() async {
    if (eyevalue <= 0.2) {
      eyeColor = yellow;
      return "assets/eye3.png";
    } else {
      eyeColor = eyeOpenColor;
      return "assets/eye2.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double aspectRatio = screenWidth / screenHeight;

    if (aspectRatio < 1.3) {
      aspectRatio = 1.39;
    } else if (aspectRatio < 2) {
      aspectRatio = 2.09;
    } else if (aspectRatio < 2.35) {
      aspectRatio = 2.43;
    } else {
      aspectRatio = 2.65;
    }

    bool batteryindicator = batteryp <= 20.0;
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: SizedBox(
        width: 20.0.w,
        child: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
                  child: Text(
                    'Data',
                    style: TextStyle(fontSize: 3.0.h),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Add logic to navigate to the data screen
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DataScreen()));
                },
              ),
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
                  child: Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 3.0.h),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Add logic to navigate to the dashboard screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DashboardScreen()));
                },
              ),
            ],
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenHeight * 0.02),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 80,
                  maxHeight: 604,
                ),
                // alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: LayoutBuilder(
                    builder: (context, constraints) => CustomPaint(
                      painter: PathPainter(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TimeAndTemp(constraints: constraints),
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(height: screenHeight * 0.03),
                                    const SpecificCarIndicators(),
                                    SizedBox(
                                      height: screenHeight * 0.07,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: screenHeight * 0.25,
                                            width: screenWidth * 0.15,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: screenWidth * 0.05),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    cornerImageAssetPath,
                                                    height: screenHeight * 0.07,
                                                    width: screenWidth * 0.07,
                                                    color: cornerImageColor,
                                                  ),
                                                  const Spacer(),
                                                  Image.asset(
                                                      'assets/low_battery.png',
                                                      height:
                                                          screenHeight * 0.05,
                                                      width: screenWidth * 0.05,
                                                      color: batteryindicator
                                                          ? red
                                                          : green),
                                                  SizedBox(
                                                    height: screenHeight * 0.01,
                                                  ),
                                                  Text(
                                                      '${batteryp.toStringAsFixed(1)} %',
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.015,
                                                          color: white))
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Image.asset(
                                                  "assets/seat_belt.png",
                                                  height: screenHeight * 0.20,
                                                  width: screenWidth * 0.20,
                                                  color: _seatbeltindicator
                                                      ? indicatorTrueColor
                                                      : primaryColor,
                                                ),
                                                Image.asset(
                                                  eyeImageAssetPath,
                                                  height: screenHeight * 0.14,
                                                  width: screenWidth * 0.11,
                                                  color: eyeColor,
                                                  fit: BoxFit.cover,
                                                ),
                                                AnimatedBuilder(
                                                  animation: animation,
                                                  child: Image.asset(
                                                    "assets/steering_wheel.png",
                                                    height: screenHeight * 0.20,
                                                    width: screenWidth * 0.20,
                                                    color: _steeringindicator
                                                        ? indicatorTrueColor
                                                        : primaryColor,
                                                  ),
                                                  builder: (context, child) =>
                                                      Transform.rotate(
                                                    angle: _steeringindicator
                                                        ? animation.value
                                                        : 0,
                                                    child: child,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.2,
                                            width: screenWidth * 0.15,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  right: screenWidth * 0.05),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Image.asset(
                                                    'assets/horn.png',
                                                    height: screenHeight * 0.05,
                                                    width: screenWidth * 0.05,
                                                    color: hornindicator
                                                        ? green
                                                        : indicatorColor,
                                                  ),
                                                  Image.asset(
                                                      'assets/sudden_brake.png',
                                                      height:
                                                          screenHeight * 0.08,
                                                      width: screenWidth * 0.08,
                                                      color: suddenbrake
                                                          ? red
                                                          : indicatorColor)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    GearAndBattery(constraints: constraints),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      // ..color = Colors.red
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.bottomRight,
        // end: a,
        colors: [primaryColor, primaryColor],
      ).createShader(const Offset(0, 0) & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0.h;

    // paint.shader = LinearGradient(colors: colors)

    Path path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width * 0.13, size.height * 0.05);
    path.lineTo(size.width * 0.31, 0);
    path.lineTo(size.width * 0.39, size.height * 0.11);
    path.lineTo(size.width * 0.60, size.height * 0.11);
    path.lineTo(size.width * 0.69, 0);
    path.lineTo(size.width * 0.87, size.height * 0.05);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width * 0.87, size.height);
    path.lineTo(size.width * 0.13, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class GearPrinter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 32, 146, 0)
      ..style = PaintingStyle.fill;

    // paint.shader = LinearGradient(colors: colors)
    double strokeWidth = 0.35.h;
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.08, size.height * 0.5);
    path.lineTo(size.width * 0.34, size.height * 0.5);
    path.lineTo(size.width * 0.42, 0);
    path.lineTo(size.width * 0.48, 0);
    path.lineTo(size.width * 0.48, strokeWidth);
    path.lineTo(size.width * 0.42, strokeWidth);
    path.lineTo(size.width * 0.34, size.height * 0.5 + strokeWidth);
    path.lineTo(size.width * 0.11, size.height * 0.5 + strokeWidth);
    // path.moveTo(size.width * 0.52, 0);

    path.close();
    canvas.drawPath(path, paint);

    Path path2 = Path();
    path2.moveTo(size.width * 0.52, 0);
    path2.lineTo(size.width * 0.58, 0);
    path2.lineTo(size.width * 0.66, size.height * 0.5);
    path2.lineTo(size.width * 0.90, size.height * 0.5);
    path2.lineTo(size.width, size.height);
    path2.lineTo(size.width * 0.87, size.height * 0.5 + strokeWidth);
    path2.lineTo(size.width * 0.66, size.height * 0.5 + strokeWidth);
    path2.lineTo(size.width * 0.58, strokeWidth);
    path2.lineTo(size.width * 0.52, strokeWidth);

    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/*drawer: SizedBox(
        width: 20.0.w,
        child: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(top: 10,right: 20,left: 20),
                  child: Text('Data',style: TextStyle(fontSize: 3.0.h),),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Add logic to navigate to the data screen
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DataScreen()));
                },
              ),
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(top: 10,right: 20,left: 20),
                  child: Text('Dashboard',style: TextStyle(fontSize: 3.0.h),),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Add logic to navigate to the dashboard screen
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()));
                },
              ),
            ],
          ),
        ),
*/