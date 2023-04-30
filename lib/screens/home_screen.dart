import 'package:flutter/material.dart';

import '../classes/nav_drawer.dart';
import '../design/styles.dart';
import '../design/tw_colors.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

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
