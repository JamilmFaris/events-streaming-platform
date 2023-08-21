import 'package:flutter/material.dart';

import '../models/event.dart';

class PaginatedEvents with ChangeNotifier {
  List<Event> _events = [];
  final int currentIndex = 0;
  bool hasMoreEvents = true;

  List<Event> get events {
    return [..._events];
  }

  void add(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void addAll(List<Event>? events) {
    if (events != null) {
      _events.addAll(events);
      notifyListeners();
    }
  }

  Event getEvent(int id) {
    return _events.firstWhere((element) => id == element.id);
  }

  void deleteEvents() {
    _events = [];
    notifyListeners();
  }

  void deleteEvent(int id) {
    _events.removeWhere((element) => id == element.id);
    notifyListeners();
  }
}
