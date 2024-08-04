import 'package:carmodel/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// ignore: camel_case_types
class brake extends StatefulWidget {
  const brake({Key? key, this.acc = const ["LOW", "MEDIUM", "HIGH"]})
      : super(key: key);

  final List<String> acc;

  @override
  State<brake> createState() => _brstate();
}

// ignore: camel_case_types
class _brstate extends State<brake> {
  final DatabaseReference _accReference = FirebaseDatabase.instance
      // ignore: deprecated_member_use
      .reference()
      .child('rpi_sensors')
      .child('rpi_sensors')
      .child('brake');
  late int brvalue;
  Color brakeColor = lightRed;

  @override
  void initState() {
    super.initState();
    brvalue = 0;
    _accReference.onValue.listen((event) {
      if (event.snapshot.exists) {
        brvalue = event.snapshot.value as int;

        // Map the gear value to the corresponding index in widget.gears
        int mappedIndex = _getMappedIndex(brvalue);

        // Update the selectedGearIndex based on the mapped index
        setState(() {
          brvalue = mappedIndex;
        });
      }
    });
  }

  // Helper function to map gear values to corresponding index
  int _getMappedIndex(int gearvalue) {
    switch (brvalue) {
      case 0:
        brakeColor = lightRed;
        return widget.acc.indexOf("LOW");
      case 1:
        brakeColor = lightYellow;
        return widget.acc.indexOf("MEDIUM");
      case 2:
        brakeColor = lightGreen;
        return widget.acc.indexOf("HIGH");
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width:
          screenWidth * 0.15, // Increased width to accommodate the power icon
      child: Padding(
        padding: EdgeInsets.only(
            top: screenWidth * 0.01, right: screenWidth * 0.014),
        child: DefaultTextStyle(
          style: TextStyle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "Brake   ",
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 1.6.w),
              ),
              Text(
                widget.acc[brvalue],
                style: TextStyle(color: brakeColor, fontSize: 1.2.w),
              )
            ],
          ),
        ),
      ),
    );
  }
}
