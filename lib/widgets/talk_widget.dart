import 'package:events_streaming_platform/classes/event_arguments.dart';
import 'package:events_streaming_platform/design/tw_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';

class TalkWidget extends StatelessWidget {
  Talk talk;
  TalkWidget({required this.talk, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: TwColors.secondaryColor(context),
      child: ListTile(
        leading: (talk.speaker.avatar != null)
            ? CircleAvatar(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Image.network(talk.speaker.avatar!),
                ),
              )
            : null,
        title: Text(talk.title),
        subtitle: Text(
          '${DateFormat.Hms().format(talk.start)} to ${DateFormat.Hms().format(talk.end)}',
        ),
        trailing: Text(
          talk.status.statusString,
          style: EventArguments.talkStatusTextStyle,
        ),
      ),
    );
  }
}
