import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';

class EventWidget extends StatelessWidget {
  Event event;
  EventWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.network(event.picture).image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Text(event.title),
          Text(DateFormat.yMMMMEEEEd().format(event.date))
        ],
      ),
    );
  }
}
