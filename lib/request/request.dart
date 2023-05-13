import 'package:events_streaming_platform/models/current_user.dart';
import 'package:events_streaming_platform/models/event.dart';
import 'package:events_streaming_platform/models/token.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Request {
  static String authority = '192.168.1.9:8000';
  static String databaseVersion = '/v1';
  static String urlPrefix = '/api';

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

  static void login(String userName, String password) {
    var url = Uri.http(authority, '$urlPrefix$databaseVersion/auth/login');
    http.post(
      url,
      body: json.encode({
        'username': userName,
        'password': password,
      }),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((response) async {
      var j = json.decode(response.body);
      var userJson = j['user'];
      var userToken = j['token'];
      var userTokenExpiryDate = j['expiry'];
      await Token.storeToken(userToken, userTokenExpiryDate);

      User user = User(
        firstName: userJson['first_name'],
        lastName: userJson['last_name'],
        username: userJson['username'],
        email: userJson['email'],
        avatar: userJson['avatar'],
        bio: userJson['bio'],
        headline: userJson['headline'],
      );

      await CurrentUser.storeUser(user);
    });
  }

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
