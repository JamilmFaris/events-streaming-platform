import 'package:flutter/material.dart';
import 'design/styles.dart';
import 'design/tw_colors.dart';
import 'screens/home_screen.dart';
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
        '/': (_) => HomeScreen(),
        SignupScreen.routeName: (_) => SignupScreen(),
        LoginScreen.routeName: (_) => LoginScreen(),
        EditAccountScreen.routeName: (_) => EditAccountScreen(),
      },
    );
  }
}

void main() => runApp(MyApp());
