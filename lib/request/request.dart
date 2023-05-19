import 'dart:io';

import 'package:events_streaming_platform/models/current_user.dart';
import 'package:events_streaming_platform/models/event.dart';
import 'package:events_streaming_platform/models/token.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../screens/home_screen.dart';

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
    isPublished: false,
  );

  static void login(BuildContext context, String userName, String password) {
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
      if (response.statusCode == 200) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('logged in as ${user.username}')),
        );
        Navigator.of(context).pushNamed(HomeScreen.routeName);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('wrong credentials')),
      );
    });
  }

  static void signup(
    BuildContext context,
    String firstName,
    String lastName,
    String username,
    String email,
    String password,
  ) {
    var url = Uri.http(authority, '$urlPrefix$databaseVersion/auth/register');
    http.post(
      url,
      body: json.encode({
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'email': email,
        'password': password,
      }),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((response) async {
      login(context, username, password);
    });
  }

  static void editAccount(
    String firstName,
    String lastName,
    String userName,
    String email,
    String password,
    String bio,
    String headline,
  ) {}
  static Future<EventsWithHasMoreEvents> getAllEvents({
    required int offset,
    required int limit,
  }) async {
    bool hasMoreEvents = false;
    print('limit $limit offset $offset \n\n');
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/events',
      {'limit': limit.toString(), 'offset': offset.toString()},
    );

    Future<http.Response> res = http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    List<Event> events = await res.then((response) async {
      var j = json.decode(response.body);
      List<dynamic> results = j['results'];
      int count = j[
          'count']; // i've consedired that count is the remaining without the ones that I have in my response
      hasMoreEvents = (count > 0);
      List<Event> curEvents = [];
      results.forEach((element) {
        curEvents.add(
          Event(
            id: element['id'],
            title: element['title'],
            organizerName: element['organizer'],
            description: element['description'],
            picture: element['picture'],
            date: element['date'],
            isPublished: true,
          ),
        );
        print('event id is ${element['id']}');
      });
      return curEvents;
    });

    EventsWithHasMoreEvents ret = EventsWithHasMoreEvents(
      events,
      hasMoreEvents,
    );
    return ret;
  }

  static Future<int?> addTalk(
    /// returns talk's id if the request returned 201
    BuildContext context,
    int eventId,
    String speakerUsername,
    String talkTitle,
    DateTime start,
    DateTime end,
  ) async {
    String? token = await Token.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('you have to login first'),
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }
    var url =
        Uri.http(authority, '$urlPrefix$databaseVersion/events/$eventId/talks');
    http.post(
      url,
      body: json.encode({
        'speaker': speakerUsername,
        'title': talkTitle,
        'start': start.toString(),
        'end': end.toString(),
      }),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    ).then((response) async {
      if (response.statusCode == 201) {
        var j = json.decode(response.body);
        return j['id'];
      } else {
        return null;
      }
    });
  }

  static postEvent(BuildContext context, String title, String description,
      XFile file) async {
    var url = Uri.http(authority, '$urlPrefix$databaseVersion/events/');
    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", url);

    var fields = {
      'title': title,
      'description': description,
    };
    request.fields.addAll(fields);

    //create multipart using filepath, string or bytes
    var pic = await http.MultipartFile.fromPath("picture", file.path);
    //add multipart to request
    request.files.add(pic);
    String? token = await Token.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('you\'re not logged in yet'),
      ));
      return;
      print('no token');
    }
    var headers = {
      'Accept': '*/*',
      'Authorization': 'Bearer $token',
    };
    request.headers.addAll(headers);
    print('hello');
    var response = await request.send();
    print('hello');

    //Get the response from the server
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    if (response.statusCode == 201) {
      var j = json.decode(responseString);
      print(j['id']);
      return j['id'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('there is some problem'),
      ));
      return null;
    }
  }
}

class EventsWithHasMoreEvents {
  List<Event> events;
  bool hasMoreEvents;
  EventsWithHasMoreEvents(this.events, this.hasMoreEvents);
}
