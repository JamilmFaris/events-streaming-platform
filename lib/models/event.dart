import 'package:events_streaming_platform/classes/helper.dart';

import 'user.dart';

class Event {
  int id;
  String title;
  String organizerName;
  String description;
  String picture;
  DateTime date;
  bool isPublished;
  List<Talk>? talks;

  Event({
    required this.id,
    required this.title,
    required this.organizerName,
    required this.description,
    required this.picture,
    required this.date,
    required this.isPublished,
    this.talks,
  });
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      organizerName: json['organizer'],
      description: json['description'],
      picture: json['picture'],
      date: DateTime.now() /*Helper.format.parse(json['date'])*/,
      isPublished: json['is_published'],
    );
  }
}

class Talk {
  int? id;
  String title;
  late User speaker;
  DateTime start;
  DateTime end;
  TalkStatus status;
  Talk({
    this.id,
    required this.title,
    required this.speaker,
    required this.start,
    required this.end,
    this.status = TalkStatus.pending,
  });

  Talk.addTalkUsingSpeakerUsername({
    this.id,
    required this.title,
    required String speakerUsername,
    required this.start,
    required this.end,
    this.status = TalkStatus.pending,
  }) {
    speaker = User(username: speakerUsername);
  }
}

enum TalkStatus { pending, approved, rejected }

extension TalkStatusToString on TalkStatus {
  String get statusString {
    switch (this) {
      case TalkStatus.pending:
        return "pending";
      case TalkStatus.approved:
        return "approved";
      case TalkStatus.rejected:
        return "rejected";
    }
  }
}
