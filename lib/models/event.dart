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
      date: Helper.format.parse(json['started_at']),
      isPublished: json['is_published'],
    );
  }
  @override
  String toString() {
    final m = {
      'name': 'event',
      'id': id,
      'title': title,
      'organizer': organizerName,
      'description': description,
      'picture': picture,
      'date': Helper.getFormattedDateString(date),
      'is_published': isPublished,
    };
    return m.toString();
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
  factory Talk.fromJson(Map<String, dynamic> json) {
    var speakerJson = json['speaker'];
    var statusString = json['status'];
    TalkStatus status;
    if (statusString == 'pending') {
      status = TalkStatus.pending;
    } else if (statusString == 'rejected') {
      status = TalkStatus.rejected;
    } else {
      status = TalkStatus.approved;
    }
    return Talk(
      id: json['id'],
      title: json['title'],
      speaker: User.fromJson(speakerJson),
      start: Helper.getFormattedDate(json['start']),
      end: Helper.getFormattedDate(json['end']),
      status: status,
    );
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
