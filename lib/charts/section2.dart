import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:csv/csv.dart' as csv;
import 'package:flutter/services.dart';

class BrakeChart extends StatefulWidget {
  const BrakeChart({Key? key}) : super(key: key);

  @override
  _BrakeChartState createState() => _BrakeChartState();
}

class _BrakeChartState extends State<BrakeChart> {
  List<List<dynamic>> csvData = [];

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
    if (csvList.isNotEmpty && csvList[0].first == 'Acc') {
      csvList.removeAt(0);
    }

    setState(() {
      csvData = csvList;
    });
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
                  spots: _getSpots(0), // Acceleration (index 0)
                  isCurved: true,
                  color: const Color.fromARGB(255, 243, 145, 33),
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true),
                ),
                LineChartBarData(
                  spots: _getSpots(7), // Cornering (index 1)
                  isCurved: true,
                  color: Color.fromARGB(255, 0, 179, 255),
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(34, 0, 0, 0).withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Acceleration',
                style: TextStyle(
                  color: Color.fromARGB(255, 243, 145, 33),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(34, 0, 0, 0).withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Cornering',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 179, 255),
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
          final double parsedValue = double.tryParse('$value') ?? 0;

          // Display a point for the raw values
          return FlSpot(index.toDouble(), parsedValue);
        } catch (e) {
          // ignore: avoid_print
          print('Error parsing value at index $index: $e');
          return FlSpot(index.toDouble(), 0);
        }
      },
    );
  }
}
