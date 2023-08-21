import 'package:events_streaming_platform/design/tw_colors.dart';
import 'package:events_streaming_platform/screens/view_streamed_video.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../classes/event_arguments.dart';
import '../classes/helper.dart';
import '../models/current_user.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../request/request.dart';
import '../widgets/talks_widget.dart';

class EventDetailsScreen extends StatefulWidget {
  Event event;
  EventDetailsScreen({required this.event, super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late bool isBooked;
  late String username;
  Future<String> future() async {
    User? myUser = await CurrentUser.getUser();

    if (myUser != null) {
      username = myUser.username;
    }
    if (!context.mounted) return 'error';
    widget.event.talks = await Request.getTalks(
      context,
      widget.event.id,
      null,
    );
    if (!context.mounted) return 'error';
    isBooked = await Request.isEventBooked(context, widget.event.id);
    return 'done';
  }

  @override
  Widget build(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ViewStreamedVideoScreen(),
      ),
    );
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('event : ${widget.event.title}'),
      ),
      body: FutureBuilder(
        future: future(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('error ${snapshot.error}');
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Stack(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    const Color.fromARGB(255, 155, 154, 154).withOpacity(0.4),
                    BlendMode.dstATop,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.event.picture),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: TwColors.backgroundColor(context),
                            ),
                            child: Text(
                              'organizer : ${widget.event.organizerName}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: TalksWidget(
                              talks: widget.event.talks ?? [],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: TwColors.backgroundColor(context),
                            ),
                            child: Text(
                              'description : ${widget.event.description}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: TwColors.backgroundColor(context),
                            ),
                            child: Text(
                              'starts at : ${Helper.getFormattedDateWithTime(widget.event.date)}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          if (widget.event.organizerName != username &&
                              widget.event.date.isAfter(DateTime.now()))
                            EventArguments.EventFilledButton(
                              onPressed: () {
                                (isBooked)
                                    ? Request.cancelBookingEvent(
                                        context: context,
                                        eventId: widget.event.id,
                                      )
                                    : Request.bookEvent(
                                        context: context,
                                        eventId: widget.event.id,
                                      );
                                setState(() {});
                              },
                              child: (isBooked)
                                  ? const Text('cancel booking')
                                  : const Text('book event'),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          } else {
            return const Text('future does\'n have any data');
          }
        },
      ),
    );
  }
}
