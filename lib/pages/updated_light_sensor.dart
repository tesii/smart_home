
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:smart_home_monitor/main.dart';


class BrightnessControl extends StatefulWidget {
  const BrightnessControl({super.key});
  @override
  _BrightnessControlState createState() => _BrightnessControlState();
}

class _BrightnessControlState extends State<BrightnessControl> {
  double _lightLevel = 0.0;
  bool _showHighIntensityPopup = true; // Flag for showing high intensity popup
  bool _showLowIntensityPopup = true; // Flag for showing low intensity popup
  late StreamSubscription<int> _lightSubscription;

  @override
  void initState() {
    super.initState();
    _listenToLightSensor();
  }

  void _listenToLightSensor() {
    LightSensor.hasSensor().then((hasSensor) {
      if (hasSensor) {
        _lightSubscription = LightSensor.luxStream().listen((int luxValue) {
          setState(() {
            _lightLevel = luxValue.toDouble();
            checkAndTriggerPopups();
          });
        });
      } else {
        return;
      }
    });
  }

  void checkAndTriggerPopups() {
    // Check for the specific intensity values to trigger popups
    if (_lightLevel >= 20000.0 && _showHighIntensityPopup) {
      _showNotification('Deam light', 'High ambient light levels.');
      _showHighIntensityPopup =
      false; // Prevent further high intensity popups until condition resets
    } else if (_lightLevel < 20000.0) {
      _showHighIntensityPopup = true; // Reset the flag when not at 40000
    }

    if (_lightLevel <= 5 && _showLowIntensityPopup) {
      _showNotification('Bright light', 'Low ambient light levels.');
      _showLowIntensityPopup =
      false; // Prevent further low intensity popups until condition resets
    } else if (_lightLevel != 0) {
      _showLowIntensityPopup = true; // Reset the flag when not at 0
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Light Sensor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Light Level: ${_lightLevel.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Container(
              width: 50,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.brown),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.orange,),
                    width: 50,
                    height: 10 * _lightLevel,

                  ),
                  Icon(
                    Icons.lightbulb,
                    size: 50,
                    color: Colors.yellow[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotification(String header, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'LightSensor_channel', // Change this to match your channel ID
      'Light Sensor Notifications', // Replace with your own channel name
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      header,
      body,
      platformChannelSpecifics,
    );
  }
}