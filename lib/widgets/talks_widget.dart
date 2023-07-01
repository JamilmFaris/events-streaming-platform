import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dialogs/input_talk.dart';
import '../models/event.dart';
import 'talk_widget.dart';

class TalksWidget extends StatelessWidget {
  List<Talk> talks;

  TalksWidget({
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

    return Container(
      padding: const EdgeInsets.all(10),
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
                return ExpansionTile(
                  title: Text(labeledTalks[i].label),
                  children: labeledTalks[i]
                      .talks
                      .map((talk) => TalkWidget(talk: talk))
                      .toList(),
                );
              },
              itemCount: labeledTalks.length,
            ),
    );
  }
}

class LabledTalks {
  String label;
  List<Talk> talks;
  LabledTalks(this.label, this.talks);
}
