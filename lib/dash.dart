import 'package:carmodel/charts/section1.dart';
import 'package:carmodel/charts/section2.dart';
import 'package:carmodel/charts/section3.dart';
import 'package:carmodel/charts/section4.dart';
import 'package:carmodel/charts/section5.dart';
import 'package:carmodel/charts/section6.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;

void main() {
  runApp(const MaterialApp(
    home: DashboardScreen(),
  ));
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<List<dynamic>> csvData;
  static int totalRow = 0;
  static int acceleration = 0;
  static int brake = 0;
  static int brakeCorner = 0;
  static int brakeCornerCount = 0; // New variable

  @override
  void initState() {
    super.initState();
    _loadCSVData();
  }

  Future<void> _loadCSVData() async {
    final String data = await rootBundle.loadString('assets/csv/ILP.csv');
    final List<List<dynamic>> csvList =
        const CsvToListConverter().convert(data);

    // Skip the first row (header) if it exists
    if (csvList.isNotEmpty && csvList[0].first == 'Brake') {
      csvList.removeAt(0);
    }

    int accelerationCount = _countOccurrences(
        csvList, 1, 3); // Assuming the column index for 'Acc' is 1
    int brakeCount = _countOccurrences(
        csvList, 0, 3); // Assuming the column index for 'Brake' is 0
    brakeCornerCount = _countBrakeCornerOccurrences(csvList);

    setState(() {
      csvData = csvList;
      totalRow = csvData.length;
      acceleration = accelerationCount;
      brake = brakeCount;
      brakeCorner = brakeCornerCount; // Assign the new variable to brakeCorner
    });
  }

  int _countOccurrences(
      List<List<dynamic>> data, int columnIndex, dynamic targetValue) {
    return data.where((row) => row[columnIndex] == targetValue).length;
  }

  int _countBrakeCornerOccurrences(List<List<dynamic>> data) {
    int count = 0;
    for (var row in data) {
      int brakeValue = int.tryParse('${row[0]}') ??
          -1; // Assuming the column index for 'Brake' is 0
      int corneringValue = int.tryParse('${row[7]}') ??
          -1; // Assuming the column index for 'Cornering' is 2

      if (brakeValue == 3 && corneringValue == 1) {
        count++;
      }
    }
    return count;
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth <= 600) ? 1 : 3; // Adjust the threshold as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _calculateCrossAxisCount(context),
                childAspectRatio: 1.7,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, index) {
                return DashboardCard(index + 1);
              },
            ),
            const SizedBox(height: 16),
            const Rating(
              title: 'Driver Behaviour',
              section: 1,
            ),
            const Rating(
              title: 'Vehicle condition rating',
              section: 2,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final int sectionNumber;

  const DashboardCard(this.sectionNumber, {Key? key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.blue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            _buildChart(context),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    switch (sectionNumber) {
      case 1:
        return const brac();
      case 2:
        return const BrakeChart();
      case 3:
        return const LineChartWidget();
      case 4:
        return const corner();
      case 5:
        return const Steer();
      case 6:
        return const BrakePieChart();
      default:
        return Container();
    }
  }
}

class Rating extends StatelessWidget {
  final String title;
  final int section;

  const Rating({required this.title, required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TenStarRatingBar(section: section),
        ),
      ],
    );
  }
}

class TenStarRatingBar extends StatefulWidget {
  final int section;

  const TenStarRatingBar({required this.section});

  @override
  _TenStarRatingBarState createState() => _TenStarRatingBarState();
}

class _TenStarRatingBarState extends State<TenStarRatingBar> {
  late Map<int, double> _ratings;

  @override
  void initState() {
    super.initState();

    _initRatings();
  }

  void _initRatings() {
    int ac = _DashboardScreenState.acceleration;
    int tot = _DashboardScreenState.totalRow;
    int bra = _DashboardScreenState.brake;
    int bracor = _DashboardScreenState.brakeCorner;
    int bc = _DashboardScreenState.brakeCornerCount;

    double percentage = ((ac + bra) / tot) * 100;

    if (percentage <= 25) {
      _ratings = {1: 9.0, 2: 3.0};
    } else {
      num starRating = (10 - ((percentage - 25) / 10)).clamp(1, 9);
      _ratings = {1: starRating.toDouble(), 2: 3.0};
    }

    double cornerPercentage = ((bracor + bc) / tot) * 100;

    if (cornerPercentage <= 25) {
      _ratings[2] = 9.0;
    } else {
      num cornerStarRating = (10 - ((cornerPercentage - 25) / 10)).clamp(1, 9);
      _ratings[2] = cornerStarRating.toDouble();
    }
  }

  double _calculateStarSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth <= 600) ? 20 : 16;
  }

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: _ratings[widget.section] ?? 10,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 10,
      itemSize: _calculateStarSize(context),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
        size: _calculateStarSize(context),
      ),
      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      ignoreGestures: true,
      onRatingUpdate: (rating) {},
    );
  }
}
