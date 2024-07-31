import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:smart_home_monitor/const/constant.dart';
import 'package:smart_home_monitor/main.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng _kigaliCenter = LatLng(-1.9441, 30.0619); // Coordinates for Kigali center
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  static const LatLng _pApplePark = LatLng(37.3346, -122.0090);
  LatLng? _currentP;
  Map<PolylineId, Polyline> polylines = {};
  Map<PolygonId, Polygon> _polygons = {};
  StreamSubscription<LocationData>? _locationSubscription;
  bool _notificationSentOutSide = false;
  bool _notificationSentInSide = false;

  @override
  void initState() {
    super.initState();
    getLocationUpdates().then(
          (_) {
        getPolylinePoints().then((coordinates) {
          generatePolyLineFromPoints(coordinates);
        });
      },
    );
    _createGeofence();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel(); // Cancel location updates subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _currentP == null
          ? const Center(
        child: Text("Loading..."),
      )
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) => _mapController.complete(controller),
        initialCameraPosition: CameraPosition(
          target: _kigaliCenter,
          zoom: 13,
        ),
        polygons: Set<Polygon>.of(_polygons.values),
        markers: {
          Marker(
            markerId: MarkerId("_currentLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position: _currentP!,
          ),
          Marker(
            markerId: MarkerId("_sourceLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position: _pGooglePlex,
          ),
          Marker(
            markerId: MarkerId("_destinationLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position: _pApplePark,
          ),
        },
        polylines: Set<Polyline>.of(polylines.values),
      ),
    );
  }

  void _triggerInSideNotification() async {
    if (!_notificationSentInSide) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Map_channel', // Change this to match your channel ID
        'Map Notifications', // Replace with your own channel name
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Map',
        'Get things done! You are in your work environment',
        platformChannelSpecifics,
      );
      print('Inside geofence notification sent');
      _notificationSentInSide = true;
      _notificationSentOutSide = false;
    }
  }

  void _triggerOutSideNotification() async {
    if (!_notificationSentOutSide) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Map_channel', // Change this to match your channel ID
        'Map Notifications', // Replace with your own channel name
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Map',
        'You are outside your work area',
        platformChannelSpecifics,
      );
      print('Outside geofence notification sent');
      _notificationSentOutSide = true;
      _notificationSentInSide = false;
    }
  }

  void _createGeofence() {
    // Define the boundaries for the larger geofence around Kigali
    List<LatLng> workBoundaries = [
      LatLng(-1.94506, 30.05878),
      LatLng(-1.94851, 30.06041),
      LatLng(-1.95125, 30.05341),
      // LatLng(-1.8980, 30.0274), // Southwest corner
    ];

    // Create a polygon to represent the geofence boundaries
    PolygonId polygonId = PolygonId('kigali');
    Polygon polygon = Polygon(
      polygonId: polygonId,
      points: workBoundaries,
      strokeWidth: 2,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.3),
    );

    // Add the polygon to the map
    setState(() {
      _polygons[polygonId] = polygon;
    });

    // Start location updates subscription to monitor device's location
    _startLocationUpdates();
  }

  void _startLocationUpdates() async {
    _locationSubscription = _locationController.onLocationChanged.listen((LocationData currentLocation) {
      // Check if the device's location is inside or outside the geofence
      bool insideGeofence = _isLocationInsideGeofence(currentLocation.latitude!, currentLocation.longitude!);

      if (insideGeofence && !_notificationSentInSide) {
        _triggerInSideNotification();
        _notificationSentInSide = true;
        _notificationSentOutSide = false;
      } else if (!insideGeofence && !_notificationSentOutSide) {
        _triggerOutSideNotification();
        _notificationSentOutSide = true;
        _notificationSentInSide = false;
      }
    });
  }

  bool _isLocationInsideGeofence(double latitude, double longitude) {
    // Check if the provided location is inside the geofence boundaries
    bool isInside = false;
    List<LatLng> workBoundaries = [
      LatLng(-1.94506, 30.05878),
      LatLng(-1.94851, 30.06041),
      LatLng(-1.95125, 30.05341),
      // LatLng(-1.8980, 30.0274),
    ];

    // Algorithm to determine if a point is inside a polygon
    int i, j = workBoundaries.length - 1;
    for (i = 0; i < workBoundaries.length; i++) {
      if ((workBoundaries[i].latitude < latitude &&
          workBoundaries[j].latitude >= latitude ||
          workBoundaries[j].latitude < latitude &&
              workBoundaries[i].latitude >= latitude) &&
          (workBoundaries[i].longitude <= longitude ||
              workBoundaries[j].longitude <= longitude)) {
        if (workBoundaries[i].longitude +
            (latitude - workBoundaries[i].latitude) /
                (workBoundaries[j].latitude - workBoundaries[i].latitude) *
                (workBoundaries[j].longitude - workBoundaries[i].longitude) <
            longitude) {
          isInside = !isInside;
        }
      }
      j = i;
    }
    return isInside;
  }

  Future<List<LatLng>> getPolylinePoints() async {
    // This is a dummy implementation. Replace with your actual logic to fetch or generate polyline coordinates.
    // For example, you might fetch this data from an API or generate it based on some logic.

    // Dummy coordinates for illustration
    List<LatLng> coordinates = [
      LatLng(-1.9441, 30.0619),
      LatLng(-1.9450, 30.0620),
      LatLng(-1.9460, 30.0630),
      // Add more points as needed
    ];

    // Simulating a network call or processing delay
    await Future.delayed(Duration(seconds: 2));

    return coordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<void> getLocationUpdates() async {
    try {
      // Check and request location permissions if necessary
      final permissionStatus = await _locationController.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        await _locationController.requestPermission();
      }

      // Verify if permission is granted
      if (await _locationController.hasPermission() == PermissionStatus.granted) {
        // Get current location
        LocationData currentLocation = await _locationController.getLocation();

        setState(() {
          _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });

        // Start location updates
        _startLocationUpdates();
      }
    } catch (e) {
      print('Error getting location updates: $e');
    }
  }
}
