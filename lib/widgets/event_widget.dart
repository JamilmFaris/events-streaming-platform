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
              child: Image.network(
                event.picture,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(event.title),
          Text(DateFormat.yMMMMEEEEd().format(event.date))
        ],
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
