import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart' as csv;
import 'package:flutter/services.dart';

class Steer extends StatefulWidget {
  const Steer({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SteerState createState() => _SteerState();
}

class _SteerState extends State<Steer> {
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
    if (csvList.isNotEmpty && csvList[0].first == 'Brake') {
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
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                    color: const Color.fromARGB(0, 255, 255, 255), width: 1),
              ),
              minX: 0,
              maxX: findMaxValue(csvData, 0) + 25,
              minY: 0,
              maxY: 3,
              lineBarsData: [
                LineChartBarData(
                  spots: _getSpots(1), // Use 0 as the column index for 'Brake'
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: true),
                ),
                LineChartBarData(
                  spots: _getSpots(
                      17), // Use 18 as the column index for 'Steering Position'
                  isCurved: true,
                  color: Colors
                      .red, // You can use a different color for the second line
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
                color: const Color.fromARGB(192, 43, 42, 41),
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
                color: const Color.fromARGB(192, 43, 42, 41),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Steering Position',
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
          // Divide the 'Steering Position' values by 10
          final double adjustedValue =
              columnIndex == 17 ? parsedValue / 100 : parsedValue;
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
