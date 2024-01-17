import 'package:carmodel/constants.dart';
import 'package:carmodel/d.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TimeAndTemp extends StatefulWidget {
  const TimeAndTemp({
    Key? key,
    required this.constraints,
  }) : super(key: key);

  final BoxConstraints constraints;

  @override
  State<TimeAndTemp> createState() => _TimeAndTempState();
}

class _TimeAndTempState extends State<TimeAndTemp>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();

    _currentTime = DateTime.now();

    // Initialize AnimationController with a duration of 1 second
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Set up a listener to update the UI whenever the animation ticks
    _controller.addListener(() {
      setState(() {
        _currentTime = DateTime.now();
      });
    });

    // Start the animation and repeat it indefinitely
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: widget.constraints.maxWidth * 0.21,
      height: widget.constraints.maxHeight * 0.11,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.titleMedium!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: screenWidth * 0.02,
                  color: Colors.grey.shade300,
                ),
                Text(
                  ' ${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 1.4.w),
                ),
              ],
            ),
            const Spacer(),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyApp(),
                    ),
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                  child: SizedBox(
                    height: screenHeight * 0.05,
                    width: screenWidth * 0.05,
                    child: Center(
                        child: Text(
                      "INSIGHT",
                      style: TextStyle(fontSize: 1.1.w, color: white),
                    )),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
