import 'package:smart_home_monitor/model/health_model.dart';

class HealthDetails {
  final healthData = const [
    HealthModel(
        icon: 'images/burn.png', value: "305", title: "Calories burned"),
    HealthModel(
        icon: 'images/steps.png', value: "10,983", title: "Steps"),
    HealthModel(
        icon: 'images/distance.png', value: "7km", title: "Distance"),
    HealthModel(icon: 'images/sleep.png', value: "7h48m", title: "Sleep"),
  ];
}
