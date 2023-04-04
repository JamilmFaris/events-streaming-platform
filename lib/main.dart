import 'package:events_streaming_platform/classes/helper.dart';
import 'package:flutter/material.dart';

import 'classes/nav_drawer.dart';
import 'classes/route_details.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/edit_account_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.grey,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey.shade800,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      routes: {
        '/': (_) => MainPage(),
        SignUpScreen.routeName: (_) => SignUpScreen(),
        LoginScreen.routeName: (_) => LoginScreen(),
        EditAccountScreen.routeName: (_) => EditAccountScreen(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);
  // just add routesDetails here and boom it will be in the drawer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer.getDrawer(context),
      appBar: AppBar(
        title: const Text('Main page'),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10.0),
                child: const Text(
                  'upcoming events',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget authButton(String title, BuildContext context, String routeName) {
  return TextButton(
    onPressed: () => Navigator.pushNamed(context, routeName),
    child: Text(title),
  );
}

void main() => runApp(MyApp());
