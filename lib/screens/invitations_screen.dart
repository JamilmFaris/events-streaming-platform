import 'package:flutter/material.dart';

import '../design/tw_colors.dart';
import '../models/event.dart';
import '../request/request.dart';
import '../widgets/invitations_widget.dart';

class InvitationsScreen extends StatefulWidget {
  static const String routeName = '/invitations';
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  Future<List<Talk>> get getInvitations async {
    return await Request.getInvitations(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwColors.backgroundColor(context),
      appBar: AppBar(title: const Text('your invitations')),
      body: FutureBuilder(
          future: getInvitations,
          builder: (BuildContext context, AsyncSnapshot<List<Talk>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              if (snapshot.data != null) {
                return InvitationsWidget(
                  invitations: snapshot.data ?? [],
                );
              } else {
                return const Center(
                  child: Text(
                    'There are no invitations\n for you today',
                    style: TextStyle(fontSize: 30),
                  ),
                );
              }
            }
          }),
    );
  }
}
