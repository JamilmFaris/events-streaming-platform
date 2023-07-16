import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dialogs/input_talk.dart';
import '../models/event.dart';
import '../request/request.dart';
import 'talk_widget.dart';

class EditTalksWidget extends StatelessWidget {
  List<Talk> talks;
  int eventId;
  void Function(Talk) addTalkToParent;

  EditTalksWidget({
    required this.eventId,
    required this.addTalkToParent,
    required this.talks,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat.yMMMd();
    Set<String> dates;
    dates = <String>{};
    for (Talk talk in talks) {
      dates.add(formatter.format(talk.start));
    }
    Map<String, List<Talk>> talksToView = Map.from({});
    for (Talk talk in talks) {
      if (talksToView[formatter.format(talk.start)] == null) {
        talksToView[formatter.format(talk.start)] = [talk];
      } else {
        talksToView[formatter.format(talk.start)]!.add(talk);
      }
    }

    List<LabledTalks> labeledTalks = [];
    talksToView.forEach((key, value) {
      labeledTalks.add(LabledTalks(key, value));
    });

    return Column(
      children: [
        const Center(
          child: Text(
            'events\' talks',
            style: TextStyle(fontSize: 20),
          ),
        ),
        Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(border: Border.all()),
            height: 200,
            child: (talks.isEmpty)
                ? const Center(
                    child: Text(
                      'There are no talks yet',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : ListView.builder(
                    itemBuilder: (_, i) {
                      return (i < labeledTalks.length)
                          ? ExpansionTile(
                              title: Text(labeledTalks[i].label),
                              children: labeledTalks[i]
                                  .talks
                                  .map(
                                    (talk) => Dismissible(
                                      key: ValueKey<int>(talk.id!),
                                      child: TalkWidget(talk: talk),
                                      confirmDismiss: (direction) async {
                                        return await confirmDelete(
                                            context, talk.id!);
                                      },
                                    ),
                                  )
                                  .toList(),
                            )
                          : IconButton(
                              onPressed: () => inputTalkDialog(context),
                              icon: const Icon(Icons.add),
                            );
                    },
                    itemCount: labeledTalks.length + 1,
                  )),
      ],
    );
  }

  void inputTalkDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => InputTalk(
        eventId: eventId,
        addTalk: addTalk,
      ),
    );
  }

  void addTalk(Talk talk) {
    //widget.talks.add(talk);the parent has the list of talks and will send it to you in the next build
    addTalkToParent(talk);
  }

  Future<bool?> confirmDelete(BuildContext context, int talkId) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context1) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          actions: [
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                await Request.deleteTalk(context1, talkId);
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context1).pop(false);
              },
            ),
          ],
        );
      },
    );
  }
}

class LabledTalks {
  String label;
  List<Talk> talks;
  LabledTalks(this.label, this.talks);
}
