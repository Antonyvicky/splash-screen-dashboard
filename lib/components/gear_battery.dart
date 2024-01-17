import 'package:carmodel/accelerator.dart';
import 'package:carmodel/brake.dart';
import 'package:carmodel/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../dashboard.dart';
import 'gears.dart';

class GearAndBattery extends StatefulWidget {
  const GearAndBattery({
    Key? key,
    required this.constraints,
  }) : super(key: key);

  final BoxConstraints constraints;

  @override
  // ignore: library_private_types_in_public_api
  _GearAndBatteryState createState() => _GearAndBatteryState();
}

class _GearAndBatteryState extends State<GearAndBattery> {
  // ignore: deprecated_member_use
  final DatabaseReference _indi8Reference =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance.reference().child('COOLANT TEMP');
  // ignore: deprecated_member_use
  final DatabaseReference _indi9Reference =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance.reference().child('ENGINE TEMP');

  final DatabaseReference _brkReference =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance.reference().child('rpi_sensors').child('brake');
  late int coolant;
  late int engine1;
  late int br;

  late final BoxConstraints constraints;
  @override
  void initState() {
    super.initState();
    coolant = 0;
    engine1 = 0;
    _indi8Reference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          coolant = event.snapshot.value as int;
        });
      }
    });
    _indi9Reference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          engine1 = event.snapshot.value as int;
        });
      }
    });

    _brkReference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          br = event.snapshot.value as int;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.height;

    return SizedBox(
      // color: Colors.blueGrey.withOpacity(0.15),
      width: widget.constraints.maxWidth * 0.74,
      height: widget.constraints.maxHeight * 0.22,
      child: LayoutBuilder(
        builder: (context, gearConstraints) => Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: GearPrinter(),
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 0,
                    ),
                    Column(
                      children: [
                        const Gears(),
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight*0.055),
                          child: SizedBox(
                            width: gearConstraints.maxWidth * 0.72,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: screenWidth*0.01),
                                Text(
                                  "ENGINE TEMPERATURE: ${engine1.toStringAsFixed(1)}° C",
                                  style: TextStyle(
                                    fontSize: 1.1.w,
                                    fontWeight: FontWeight.w400,
                                    color: temperatureColor
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "COOLANT TEMPERATURE: ${coolant.toStringAsFixed(1)}° C",
                                    style: TextStyle(
                                      fontSize: 1.1.w,
                                      fontWeight: FontWeight.w400,
                                      color: temperatureColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: gearConstraints.maxHeight * 0.10,
              left: gearConstraints.maxWidth * 0.10,
              height: gearConstraints.maxHeight * 0.38,
              child: CustomPaint(
                painter: AvgWattPerKmPrinter(),
                child: const acceleration(),
              ),
            ),
            Positioned(
              top: gearConstraints.maxHeight * 0.10,
              right: gearConstraints.maxWidth * 0.12,
              width: gearConstraints.maxWidth * 0.20,
              height: gearConstraints.maxHeight * 0.38,
              child: CustomPaint(painter: OdoPrinter(), child: const brake()),
            ),
          ],
        ),
      ),
    );
  }
}

class BatteryStatusCliper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.8, 0)
      ..lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class AvgWattPerKmPrinter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 146, 29, 0)
      ..style = PaintingStyle.fill;

    // paint.shader = LinearGradient(colors: colors)
    double strokeWidth = 0.6.h;
    Path path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.35, 0)
      ..lineTo(size.width , 0)
      ..lineTo(size.width * 0.35, strokeWidth);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class OdoPrinter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromARGB(255, 146, 29, 0)
      ..style = PaintingStyle.fill;

    // paint.shader = LinearGradient(colors: colors)
    double strokeWidth = 0.6.h;
    Path path = Path()
      ..lineTo(size.width * 0.65, 0)
      ..lineTo(size.width , size.height)
      ..lineTo(size.width * 0.65, strokeWidth);
    // ..lineTo(size.width, 0);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}