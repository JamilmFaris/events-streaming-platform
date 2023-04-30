import 'package:flutter/material.dart';

import 'classes/nav_drawer.dart';
import 'design/styles.dart';
import 'design/tw_colors.dart';
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
        primaryColor: TwColors.gray,
        appBarTheme: AppBarTheme(
          shape:
              const Border.fromBorderSide(BorderSide(color: TwColors.coolGray)),
          backgroundColor: TwColors.gray,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: Styles.barTextStyle,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: TwColors.coolGray,
          backgroundColor: TwColors.gray,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      routes: {
        '/': (_) => MainPage(),
        SignupScreen.routeName: (_) => SignupScreen(),
        LoginScreen.routeName: (_) => LoginScreen(),
        EditAccountScreen.routeName: (_) => EditAccountScreen(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer.getDrawer(context),
      appBar: AppBar(
        title: const Text('Main page'),
      ),
      backgroundColor: TwColors.backgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'upcoming events',
                  style: Styles.titleStyle,
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
