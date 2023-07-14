import 'package:events_streaming_platform/screens/create_event_screen.dart';
import 'package:events_streaming_platform/screens/organized_events_screen.dart';
import 'package:flutter/material.dart';

import '../request/request.dart';
import '../screens/edit_account_screen.dart';
import '../screens/home_screen.dart';
import '../screens/invitations_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '/classes/route_details.dart';

class NavDrawer {
  // just add routesDetails here and boom it will be in the drawer
  static var routesDetails = [];
  static UserAccountsDrawerHeader userAccountsDrawerHeader(
    String username,
    String email,
    String avatarSource,
  ) {
    if (username.isEmpty) {
      return UserAccountsDrawerHeader(
        accountName: Text('no user'),
        accountEmail: Text(''),
        arrowColor: Colors.black,
        currentAccountPicture: CircleAvatar(
          backgroundImage:
              Image.asset('assets/images/profile_image.jpeg').image,
        ),
      );
    } else {
      var avatar = (avatarSource.isEmpty)
          ? Image.asset('assets/images/profile_image.jpeg')
          : Image.network(avatarSource);
      return UserAccountsDrawerHeader(
        accountName: Text(username),
        accountEmail: Text(email),
        arrowColor: Colors.black,
        currentAccountPicture: CircleAvatar(
          backgroundImage: avatar.image,
        ),
      );
    }
  }

  static Drawer getDrawer(
    BuildContext context,
    String username,
    String email,
    String avatarSource,
    bool isLoggedIn,
  ) {
    var homepageRoute = RouteDetails(
      name: 'homePage',
      routeName: HomeScreen.routeName,
      icon: Icons.home,
    );
    var signupRoute = RouteDetails(
      name: 'signup',
      routeName: SignupScreen.routeName,
      icon: Icons.app_registration,
    );
    var loginRoute = RouteDetails(
      name: 'login',
      routeName: LoginScreen.routeName,
      icon: Icons.login,
    );
    var editAccountRoute = RouteDetails(
      name: 'editAccount',
      routeName: EditAccountScreen.routeName,
      icon: Icons.edit,
    );
    var createEventRoute = RouteDetails(
      name: 'createEvent',
      routeName: CreateEventScreen.routeName,
      icon: Icons.create_new_folder_outlined,
    );
    var myOrganizedEventsRoute = RouteDetails(
      name: 'myOrganizedEvents',
      routeName: OrganizedEventsScreen.routeName,
      icon: Icons.access_alarm_sharp,
    );
    var logoutRoute = RouteDetails(
      name: 'logout',
      routeName: HomeScreen.routeName,
      icon: Icons.logout,
    );
    var invitaionsRoute = RouteDetails(
      name: 'invitations',
      routeName: InvitationsScreen.routeName,
      icon: Icons.insert_invitation,
    );

    var header = userAccountsDrawerHeader(username, email, avatarSource);
    if (isLoggedIn) {
      routesDetails = [homepageRoute];
      routesDetails.add(loginRoute);
      routesDetails.add(signupRoute);
      routesDetails.add(editAccountRoute);
      routesDetails.add(createEventRoute);
      routesDetails.add(myOrganizedEventsRoute);
      routesDetails.add(logoutRoute);
      routesDetails.add(invitaionsRoute);
    } else {
      routesDetails = [homepageRoute];
      routesDetails.add(loginRoute);
      routesDetails.add(signupRoute);
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          header,
          ...routesDetails.map((routeDetails) {
            return ListTile(
              title: Text(routeDetails.name),
              leading: Icon(routeDetails.icon),
              onTap: () {
                if (routeDetails.name == 'logout') {
                  Request.logout(context);
                  Navigator.pushNamed(
                    context,
                    routeDetails.routeName,
                    arguments: 'logout',
                  );
                } else {
                  Navigator.pushNamed(
                    context,
                    routeDetails.routeName,
                  );
                }
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
