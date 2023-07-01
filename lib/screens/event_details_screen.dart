import 'package:events_streaming_platform/design/tw_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../widgets/talks_widget.dart';

class EventDetailsScreen extends StatefulWidget {
  Event event;
  EventDetailsScreen({required this.event, super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TwColors.backgroundColor(context),
      appBar: AppBar(
        title: Text('event ${widget.event.title}'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: 0.25 * screenSize.height,
                width: 0.25 * screenSize.width,
                child: Image.network(
                  widget.event.picture,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: TalksWidget(
                  talks: widget.event.talks ?? [],
                ),
              ),
              Text(
                widget.event.title,
                style: const TextStyle(fontSize: 20),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: Text(
                  DateFormat.yMMMMEEEEd().format(widget.event.date),
                  style: const TextStyle(fontSize: 20),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
