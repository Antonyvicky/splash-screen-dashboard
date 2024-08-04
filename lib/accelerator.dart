import 'package:carmodel/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// ignore: camel_case_types
class acceleration extends StatefulWidget {
  const acceleration({Key? key, this.acc = const ["LOW", "MEDIUM", "HIGH"]})
      : super(key: key);

  final List<String> acc;

  @override
  State<acceleration> createState() => _accstate();
}

class _accstate extends State<acceleration> {
  final DatabaseReference _accReference = FirebaseDatabase.instance
      .reference()
      .child('rpi_sensors')
      .child('rpi_sensors')
      .child('acceleration');
  late int accvalue;
  Color accColor = lightRed;

  @override
  void initState() {
    super.initState();
    accvalue = 0;
    _accReference.onValue.listen((event) {
      if (event.snapshot.exists) {
        accvalue = event.snapshot.value as int;

        // Map the gear value to the corresponding index in widget.gears
        int mappedIndex = _getMappedIndex(accvalue);

        // Update the selectedGearIndex based on the mapped index
        setState(() {
          accvalue = mappedIndex;
        });
      }
    });
  }

  // Helper function to map gear values to corresponding index
  int _getMappedIndex(int gearvalue) {
    switch (accvalue) {
      case 0:
        accColor = lightRed;
        return widget.acc.indexOf("LOW");
      case 1:
        accColor = lightYellow;
        return widget.acc.indexOf("MEDIUM");
      case 2:
        accColor = lightGreen;
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
        padding:
            EdgeInsets.only(top: screenWidth * 0.01, left: screenWidth * 0.014),
        child: DefaultTextStyle(
          style: TextStyle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "Accn   ",
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 1.6.w),
              ),
              Text(
                widget.acc[accvalue],
                style: TextStyle(color: accColor, fontSize: 1.2.w),
              )
            ],
          ),
        ),
      ),
    );
  }
}
