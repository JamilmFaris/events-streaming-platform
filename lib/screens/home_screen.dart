import 'package:events_streaming_platform/request/request.dart';
import 'package:events_streaming_platform/widgets/event_widget.dart';
import 'package:flutter/material.dart';

import '../classes/nav_drawer.dart';
import '../design/styles.dart';
import '../design/tw_colors.dart';
import '../models/event.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Event> events = Request.getEvents();
    return Scaffold(
      drawer: NavDrawer.getDrawer(context),
      appBar: AppBar(
        title: const Text('Upcoming Events'),
      ),
      backgroundColor: TwColors.backgroundColor(context),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (_, i) {
          return EventWidget(event: events[i]);
        },
        itemCount: events.length,
      ),
    );
  }
}
