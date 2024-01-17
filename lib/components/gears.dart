import 'package:carmodel/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Gears extends StatefulWidget {
  const Gears({
    Key? key,
    this.gears = const ["N", "1", "2", "3", "4", "5"],
  }) : super(key: key);

  final List<String> gears;

  @override
  State<Gears> createState() => _GearsState();
}

class _GearsState extends State<Gears> {
  int selectedGearIndex = 0;

  final DatabaseReference _gearReference =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance
          // ignore: deprecated_member_use
          .reference()
          .child('rpi_sensors')
          .child('gear');

  @override
  void initState() {
    super.initState();
    _gearReference.onValue.listen((event) {
      if (event.snapshot.exists) {
        // Get the gear value from the Realtime Database
        int gearValue = event.snapshot.value as int;

        // Map the gear value to the corresponding index in widget.gears
        int mappedIndex = _getMappedIndex(gearValue);

        // Update the selectedGearIndex based on the mapped index
        setState(() {
          selectedGearIndex = mappedIndex;
        });
      }
    });
  }

  // Helper function to map gear values to corresponding index
  int _getMappedIndex(int gearValue) {
    switch (gearValue) {
      case 0:
        return widget.gears.indexOf("N");
      case 1:
        return widget.gears.indexOf("1");
      case 2:
        return widget.gears.indexOf("2");
      case 3:
        return widget.gears.indexOf("3");
      case 4:
        return widget.gears.indexOf("4");
      case 5:
        return widget.gears.indexOf("5");
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth*0.12,
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              widget.gears.length,
              (index) => Text(
                widget.gears[index],
                style: TextStyle(
                  color: index == selectedGearIndex
                      ? primaryColor
                      : indicatorColor,
                  fontSize: 2.0.w
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
