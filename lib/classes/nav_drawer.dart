import 'package:events_streaming_platform/screens/create_event_screen.dart';
import 'package:flutter/material.dart';

import '../screens/edit_account_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '/classes/route_details.dart';

class NavDrawer {
  // just add routesDetails here and boom it will be in the drawer
  static var routesDetails = [
    RouteDetails(
      name: 'homePage',
      routeName: '/',
      icon: Icons.home,
    ),
    RouteDetails(
      name: 'signup',
      routeName: SignupScreen.routeName,
      icon: Icons.app_registration,
    ),
    RouteDetails(
      name: 'login',
      routeName: LoginScreen.routeName,
      icon: Icons.login,
    ),
    RouteDetails(
      name: 'editAccount',
      routeName: EditAccountScreen.routeName,
      icon: Icons.edit,
    ),
    RouteDetails(
      name: 'createEvent',
      routeName: CreateEventScreen.routeName,
      icon: Icons.create_new_folder_outlined,
    ),
  ];
  static UserAccountsDrawerHeader get userAccountsDrawerHeader {
    return UserAccountsDrawerHeader(
      accountName: Text('jamil faris'),
      accountEmail: Text('jamilfaris2000@gmail.com'),
      arrowColor: Colors.black,
      currentAccountPicture: CircleAvatar(
        backgroundImage: Image.asset('assets/images/profile_image.jpeg').image,
      ),
    );
  }

  static Drawer getDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          userAccountsDrawerHeader,
          ...routesDetails.map((routeDetails) {
            return ListTile(
              title: Text(routeDetails.name),
              leading: Icon(routeDetails.icon),
              onTap: () {
                Navigator.pushNamed(context, routeDetails.routeName);
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
