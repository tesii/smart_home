import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:smart_home_monitor/motion_detector.dart';
import 'package:smart_home_monitor/pages/compass.dart';
import 'package:smart_home_monitor/pages/map_utils.dart';
import 'package:smart_home_monitor/pages/step_counter.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:smart_home_monitor/pages/updated_light_sensor.dart';


class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}


class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  late final StreamSubscription<int> listen;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  //Current brightness level;
  // double _currentLuxValue = 0.0;
  //Brightness _brightness = Brightness.light;

  final List<Widget> _pages = [
    MotionDetector(),
    StepsCounterPage(),
    BrightnessControl(),
    //CompassPage(),
    MapPage(),
  ];

//   @override
//   void initState() {
//     super.initState();
//     listen = LightSensor.luxStream().listen((lux) {
//       print("Lux value: $lux");
//       setState(() {
//         _currentLuxValue = lux.toDouble();
//         print("Double value: $_currentLuxValue");
//         // Adjust brightness based on the lux value
//         _brightness = _currentLuxValue < 20000 ? Brightness.dark : Brightness.light;
//       });
//     }, onError: (error) {
//   print("Error receiving lux data: $error"); // Check if there are any errors
// });
//   }

  @override
  void dispose() {
    // listen.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // brightness: _brightness, // Use the brightness variable here
      ),
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Sensors',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: GNav(
          backgroundColor: Colors.black,
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: Colors.grey.shade800,
          gap: 8,
          padding: EdgeInsets.all(16),
          tabs: [
            GButton(
              icon: Icons.home,
              text: 'Dashboard',
            ),
            GButton(
              icon: Icons.circle,
              text: 'Steps Counter',
            ),
            GButton(
              icon: Icons.light,
              text: 'Light Sensor',
            ),
            GButton(
              icon: Icons.location_city,
              text: 'GPS',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

// Rest of your code
}