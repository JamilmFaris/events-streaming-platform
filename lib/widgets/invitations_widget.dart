import 'package:events_streaming_platform/design/tw_colors.dart';
import 'package:flutter/material.dart';

import '../models/event.dart';
import 'invitation_widget.dart';

class InvitationsWidget extends StatelessWidget {
  List<Talk> invitations;
  InvitationsWidget({super.key, required this.invitations});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: invitations.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: TwColors.secondaryColor(context)),
          ),
          child: InvitationWidget(
            talk: invitations[index],
            key: ValueKey(index),
          ),
        );
      },
    );
  }
}
