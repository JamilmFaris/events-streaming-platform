import 'user.dart';

class Event {
  int id;
  String title;
  String organizerName;
  String description;
  String picture;
  DateTime date;
  bool isPublished;
  Agenda? agenda;

  Event({
    required this.id,
    required this.title,
    required this.organizerName,
    required this.description,
    required this.picture,
    required this.date,
    required this.isPublished,
  });
}

class Agenda {
  List<Talk> talks = [];
  Agenda.empty();
  Agenda({required this.talks});
}

class Talk {
  int id;
  String title;
  User speaker;
  DateTime start;
  DateTime end;
  Talk({
    required this.id,
    required this.title,
    required this.speaker,
    required this.start,
    required this.end,
  });
}

enum TalkStatus { pending, approved, rejected }
