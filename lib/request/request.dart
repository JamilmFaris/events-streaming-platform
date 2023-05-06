import 'package:events_streaming_platform/models/event.dart';

abstract class Request {
  static String pic = "https://loremflickr.com/320/240/dog";
  static Event event = Event(
    id: 1,
    title: "event title",
    date: DateTime.now(),
    description: "desc",
    organizerName: "jamil",
    picture: pic,
    isPublished: true,
  );
  static void login(String userName, String password) {}

  static void signup(
    String firstName,
    String lastName,
    String userName,
    String email,
    String password,
  ) {}

  static void editAccount(
    String firstName,
    String lastName,
    String userName,
    String email,
    String password,
    String bio,
    String headline,
  ) {}
  static List<Event> getEvents() {
    List<Event> events = [
      Event(
        id: 1,
        title: "event title",
        date: DateTime.now(),
        description: "desc",
        organizerName: "jamil",
        picture: pic,
        isPublished: true,
      ),
      event,
      event,
      event,
      event,
      event,
      event,
    ];

    return events;
  }
}
