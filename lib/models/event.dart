import 'package:events_streaming_platform/classes/helper.dart';

import '../request/request.dart';
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
  bool isBooked;

  Event({
    required this.id,
    required this.title,
    required this.organizerName,
    required this.description,
    required this.picture,
    required this.date,
    required this.isPublished,
    required this.isBooked,
    this.talks,
  });
  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime date;
    try {
      date = Helper.format.parse(json['started_at']);
    } catch (e) {
      date = Helper.format2.parse(json['started_at']);
    }
    date = date.add(Duration(hours: 3));
    String? pic = json['picture'];
    if (pic != null) {
      pic = 'http://${Request.authority}$pic';
    } else {
      pic = 'https://dummyimage.com/400x200/000000/ffffff';
    }

    return Event(
      id: json['id'],
      title: json['title'],
      organizerName: json['organizer'],
      description: json['description'],
      picture: pic,
      date: date,
      isPublished: json['is_published'],
      isBooked: json['is_booked'],
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
  int eventId;
  Talk({
    this.id,
    required this.title,
    required this.speaker,
    required this.start,
    required this.end,
    required this.eventId,
    this.status = TalkStatus.pending,
  });

  Talk.addTalkUsingSpeakerUsername({
    this.id,
    required this.title,
    required String speakerUsername,
    required this.start,
    required this.end,
    this.status = TalkStatus.pending,
    required this.eventId,
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
      eventId: json['event'],
      speaker: User.fromJson(speakerJson),
      start: Helper.getFormattedDate(json['start']),
      end: Helper.getFormattedDate(json['end']),
      status: status,
    );
  }
  factory Talk.invitationFromJson(
    Map<String, dynamic> json,
    String myUsername,
  ) {
    var statusString = json['status'];
    TalkStatus status;
    if (statusString == 'pending') {
      status = TalkStatus.pending;
    } else if (statusString == 'rejected') {
      status = TalkStatus.rejected;
    } else {
      status = TalkStatus.approved;
    }
    return Talk.addTalkUsingSpeakerUsername(
      id: json['id'],
      title: json['title'],
      eventId: json['event']['id'],
      speakerUsername: myUsername,
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
