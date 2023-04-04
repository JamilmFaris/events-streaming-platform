import 'package:flutter/material.dart';

class RouteDetails {
  String name;
  int? key;
  String routeName;
  //Widget Function(BuildContext) routeScreen;
  IconData? icon;
  RouteDetails({
    this.key,
    required this.name,
    required this.routeName,
    this.icon,
  });
}
