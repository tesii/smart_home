
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pedometer/pedometer.dart';
import 'package:smart_home_monitor/main.dart';


class StepsCounterPage extends StatefulWidget {
  const StepsCounterPage();


  @override
  _StepsCounterPageState createState() => _StepsCounterPageState();
}
class _StepsCounterPageState extends State<StepsCounterPage> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  int _steps = 0; // Variable to hold the number of steps
  String _status = 'Start Walking'; // Variable to hold the pedestrian status

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    _pedestrianStatusStream.listen(onPedestrianStatusChanged).onError(onPedestrianStatusError);
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps; // Update the step count
      if (_steps == 50) {
        _triggerNotification();
      }
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status; // Update the pedestrian status
    });
  }

  void onStepCountError(error) {
    // Implement error handling logic here
    print('Failed to receive step count: $error');
  }

  void onPedestrianStatusError(error) {
    // Implement error handling logic here
    print('Failed to receive pedestrian status: $error');
  }
  void _triggerNotification() async {

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'StepCounter_channel',
      'StepCounter Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Congratulation',
      'You reached 50 steps',
      platformChannelSpecifics,
    );
    print('Motion detected! Alerting user...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Steps Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Steps: $_steps', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 20),
            Text('Status: $_status', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}