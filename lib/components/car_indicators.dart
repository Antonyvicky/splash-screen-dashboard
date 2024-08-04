import 'package:carmodel/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class CarIndicators extends StatefulWidget {
  const CarIndicators({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CarIndicatorsState createState() => _CarIndicatorsState();

  List<Widget> buildContent(BuildContext context, bool blinkRightIndicator,
      bool blinkLeftIndicator, bool headlightindicator);
}

class _CarIndicatorsState extends State<CarIndicators> {
  // ignore: deprecated_member_use
  final DatabaseReference _indi1Reference = FirebaseDatabase.instance
      // ignore: deprecated_member_use
      .reference()
      .child('rpi_sensors')
      .child('rpi_sensors')
      .child('right_in');
  final DatabaseReference _indi2Reference =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance
          // ignore: deprecated_member_use
          .reference()
          .child('rpi_sensors')
          .child('rpi_sensors')
          .child('left_in');
  final DatabaseReference _indi3Reference =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance
          // ignore: deprecated_member_use
          .reference()
          .child('rpi_sensors')
          .child('rpi_sensors')
          .child('headlight');

  late bool _blinkRightIndicator;
  late bool _blinkLeftIndicator;
  late bool _headlightindicator;

  @override
  void initState() {
    super.initState();
    _blinkRightIndicator = false;
    _blinkLeftIndicator = false;
    _headlightindicator = false;

    _indi1Reference.onValue.listen((event) {
      if (event.snapshot.exists) {
        int rightIndicatorValue = event.snapshot.value as int;
        setState(() {
          _blinkRightIndicator = rightIndicatorValue == 1;
        });
      }
    });

    _indi2Reference.onValue.listen((event) {
      if (event.snapshot.exists) {
        int leftIndicatorValue = event.snapshot.value as int;
        setState(() {
          _blinkLeftIndicator = leftIndicatorValue == 1;
        });
      }
    });
    _indi3Reference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          int headlightvalue = event.snapshot.value as int;
          _headlightindicator = headlightvalue == 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: widget.buildContent(context, _blinkRightIndicator,
          _blinkLeftIndicator, _headlightindicator),
    );
  }
}

class SpecificCarIndicators extends CarIndicators {
  const SpecificCarIndicators({Key? key}) : super(key: key);

  @override
  List<Widget> buildContent(BuildContext context, bool blinkRightIndicator,
      bool blinkLeftIndicator, bool headlightindicator) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return [
      Image.asset(
        "assets/left_indicator.png",
        height: screenHeight * 0.06,
        width: screenWidth * 0.06,
        color: (blinkLeftIndicator) ? indicatorTrueColor : indicatorColor,
      ),
      Image.asset(
        "assets/head_light.png",
        height: screenHeight * 0.07,
        width: screenWidth * 0.07,
        color: (headlightindicator) ? headlightColor : indicatorColor,
      ),
      Image.asset(
        "assets/right_indicator.png",
        height: screenHeight * 0.06,
        width: screenWidth * 0.06,
        color: (blinkRightIndicator) ? indicatorTrueColor : indicatorColor,
      ),
    ];
  }
}
