import 'package:events_streaming_platform/screens/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../classes/helper.dart';
import '../models/event.dart';
import '../screens/edit_event_details_screen.dart';

class EventWidget extends StatelessWidget {
  Event event;
  EventWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => EventDetailsScreen(
                      event: event,
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    child: Image.network(
                      event.picture,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Text(event.title),
            Text(Helper.getFormattedDateWithTime(event.date))
          ],
        ),
      ),
    );
  }

  Widget getSizedImage(Image image, double height, double width) {
    return Center(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitWidth,
            alignment: FractionalOffset.topCenter,
            image: image.image,
          ),
        ),
      ),
    );
  }
}
