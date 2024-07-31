import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_home_monitor/const/constant.dart';
import 'package:smart_home_monitor/motion_detector.dart';
import 'package:smart_home_monitor/widgets/custom_card_widget.dart';


class LineChartCard extends StatefulWidget {
  @override
  _LineChartCardState createState() => _LineChartCardState();
}

class _LineChartCardState extends State<LineChartCard> {
  List<double> _magnitudes = [];
  final int _maxMagnitudes = 10;

  void _addMagnitude(double magnitude) {
    setState(() {
      if (_magnitudes.length >= _maxMagnitudes) {
        _magnitudes.removeAt(0); // Remove the first magnitude if the list is full
      }
      _magnitudes.add(magnitude); // Add the new magnitude
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = _magnitudes.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Motion Overview",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 16 / 6,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                ),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                     sideTitles: SideTitles(
                      showTitles: false
                    )
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false
                    )
                  ),
                  bottomTitles: AxisTitles(
                     sideTitles: SideTitles(
                      showTitles: false,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toString());
                    }, 
                    )
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                    interval: 1,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toString());
                      
                    }, 
                    ),
                    
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    color: Colors.blue,
                    barWidth: 2.5,
                    belowBarData: BarAreaData(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.withOpacity(0.5),
                          Colors.transparent
                        ],
                      ),
                      show: true,
                    ),
                    dotData: FlDotData(show: false),
                    spots: spots,
                  )
                ],
                minX: 0,
                maxX: _magnitudes.length.toDouble() - 1,
                maxY: _magnitudes.reduce((value, element) => max(value, element)) + 5, // Adding 5 for padding
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}