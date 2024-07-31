import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_home_monitor/main.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class MotionDetector extends StatefulWidget {
  final double motionThreshold;
  final Function(double magnitude)? onMagnitudeChanged;

  const MotionDetector({
    Key? key,
    this.motionThreshold = 2.0,
    this.onMagnitudeChanged,
  }) : super(key: key);

  @override
  _MotionDetectorState createState() => _MotionDetectorState();
  double? get lastMagnitude => _MotionDetectorState.lastMagnitude;
}

class _MotionDetectorState extends State<MotionDetector> {
  static double? lastMagnitude;
  List<FlSpot> motionData = [];
  final int maxDataPoints = 50;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      double magnitude = _calculateMagnitude(event.x, event.y, event.z);
      if (magnitude > widget.motionThreshold) {
        setState(() {
          lastMagnitude = magnitude;
          motionData.add(FlSpot(motionData.length.toDouble(), magnitude));
          if (motionData.length > maxDataPoints) {
            motionData.removeAt(0);
            for (int i = 0; i < motionData.length; i++) {
              motionData[i] = FlSpot(i.toDouble(), motionData[i].y);
            }
          }
          if (magnitude > 13) {
            _triggerNotification();
          }
        });

        if (widget.onMagnitudeChanged != null) {
          widget.onMagnitudeChanged!(magnitude);
        } else {
          _defaultMotionDetected();
        }
      }
    });
  }

  double _calculateMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  void _triggerNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'MotionDetection_channel',
      'Motion Detection Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Motion Detected',
      'Phone motion',
      platformChannelSpecifics,
    );
    print('Motion detected! Alerting user...');
  }

  void _defaultMotionDetected() {
    // debugPrint('Default Motion Detected! Magnitude: $lastMagnitude');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.motion_photos_on, color: Colors.pink.shade900, size: 40),
                  SizedBox(width: 10),
                  Text(
                    lastMagnitude != null ? 'Last Magnitude: ${lastMagnitude!.toStringAsFixed(1)}' : 'Listening for motion...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.pink.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: motionData.isNotEmpty ? motionData.length.toDouble() : 10,
                minY: 0,
                maxY: 15,
                lineBarsData: [
                  LineChartBarData(
                    spots: motionData,
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 4,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.3)),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.blue.shade400),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),


        ],
      ),
    );
  }
}