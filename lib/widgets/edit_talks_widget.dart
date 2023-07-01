import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dialogs/input_talk.dart';
import '../models/event.dart';
import 'talk_widget.dart';

class EditTalksWidget extends StatelessWidget {
  List<Talk> talks;
  void Function(Talk) addTalkToParent;

  EditTalksWidget({
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

    return ListView.builder(
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
                        onDismissed: (direction) {},
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
    );
  }

  void inputTalkDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => InputTalk(
        addTalk: addTalk,
      ),
    );
  }

  void addTalk(Talk talk) {
    //widget.talks.add(talk);the parent has the list of talks and will send it to you in the next build
    addTalkToParent(talk);
  }

  bool confirmDelete(BuildContext context) {
    return true;
  }
}

class LabledTalks {
  String label;
  List<Talk> talks;
  LabledTalks(this.label, this.talks);
}
