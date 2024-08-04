import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart' as csv;
import 'package:flutter/services.dart';

// ignore: camel_case_types
class brac extends StatefulWidget {
  const brac({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _bracState createState() => _bracState();
}

// ignore: camel_case_types
class _bracState extends State<brac> {
  List<List<dynamic>> csvData = [];
  int totalRow = 0;
  int acceleration = 0;
  int brake = 0;
  int brakeCorner = 0;

  @override
  void initState() {
    super.initState();
    _loadCSVData();
  }

  Future<void> _loadCSVData() async {
    final String data = await rootBundle.loadString('assets/csv/ILP.csv');
    final List<List<dynamic>> csvList =
        const csv.CsvToListConverter().convert(data);

    // Skip the first row (header) if it exists
    if (csvList.isNotEmpty && csvList[0].first == 'Brake') {
      csvList.removeAt(0);
    }

    setState(() {
      csvData = csvList;
      totalRow = csvData.length;
      acceleration = _countOccurrences(
          csvData, 1, 3); // Assuming the column index for 'Acc' is 1
      brake = _countOccurrences(
          csvData, 0, 3); // Assuming the column index for 'Brake' is 0
      brakeCorner = _countBrakeCornerOccurrences(csvData);
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
      int corneringValue = int.tryParse('${row[2]}') ??
          -1; // Assuming the column index for 'Cornering' is 2

      if (brakeValue == 3 && corneringValue == 1) {
        count++;
      }
    }
    return count;
  }

  double findMaxValue(List<List<dynamic>> data, int columnIndex) {
    return data
        .map<double>((row) => double.tryParse('${row[columnIndex]}') ?? 0)
        .reduce((max, value) => value > max ? value : max);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 200,
      child: Stack(
        children: [
          LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: const Color.fromARGB(0, 255, 255, 255),
                  width: 1,
                ),
              ),
              minX: 0,
              maxX: findMaxValue(csvData, 0) + 25,
              minY: 0,
              maxY: 3,
              lineBarsData: [
                LineChartBarData(
                  spots: _getSpots(0),
                  isCurved: true,
                  color: Colors.red,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: true),
                ),
                LineChartBarData(
                  spots: _getSpots(1),
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: true),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            top: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(197, 38, 38, 38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Brake',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(197, 38, 38, 38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Acceleration',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots(int columnIndex) {
    return List.generate(
      csvData.length,
      (index) {
        final dynamic value = csvData[index][columnIndex];
        try {
          final double parsedValue = double.parse('$value');
          final double adjustedValue = parsedValue;
          return FlSpot(index.toDouble(), adjustedValue);
        } catch (e) {
          // ignore: avoid_print
          print('Error parsing value at index $index: $e');
          return FlSpot(index.toDouble(), 0);
        }
      },
    );
  }
}
