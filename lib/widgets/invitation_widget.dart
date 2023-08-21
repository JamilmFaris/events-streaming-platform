import 'package:events_streaming_platform/widgets/talk_widget.dart';
import 'package:flutter/material.dart';

import '../classes/event_arguments.dart';
import '../models/event.dart';
import '../request/request.dart';

class InvitationWidget extends StatefulWidget {
  Talk talk;
  InvitationWidget({super.key, required this.talk});

  @override
  State<InvitationWidget> createState() => _InvitationWidgetState();
}

class _InvitationWidgetState extends State<InvitationWidget> {
  @override
  Widget build(BuildContext context) {
    String buttonText = "";
    if (widget.talk.status == TalkStatus.pending) {
      buttonText = 'approve';
    } else if (widget.talk.status == TalkStatus.approved) {
      buttonText = 'reject';
    } else {
      buttonText = 'rejected';
    }
    return Column(
      children: [
        TalkWidget(key: super.widget.key, talk: widget.talk),
        if (widget.talk.start.isAfter(DateTime.now()))
          EventArguments.eventFilledButton(
            onPressed: () {
              if (widget.talk.status == TalkStatus.pending) {
                Request.changeTalkStatus(
                  context: context,
                  talkId: widget.talk.id!,
                  wantedStatus: TalkStatus.approved,
                );
              } else if (widget.talk.status == TalkStatus.approved) {
                Request.changeTalkStatus(
                  context: context,
                  talkId: widget.talk.id!,
                  wantedStatus: TalkStatus.rejected,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    'Changing status from rejected to approved is not allowed.',
                  ),
                ));
              }
            },
            child: (widget.talk.status == TalkStatus.rejected)
                ? const Text(
                    'REJECTED',
                    style: TextStyle(color: Colors.red),
                  )
                : Text(buttonText),
          )
      ],
    );
  }
}
