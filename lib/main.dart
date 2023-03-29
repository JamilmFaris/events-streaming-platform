import 'package:flutter/material.dart';

import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';

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
      },
    );
  }
}

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main page'),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              authButton('signup', context, SignUpScreen.routeName),
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
