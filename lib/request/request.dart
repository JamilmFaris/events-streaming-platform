import 'package:events_streaming_platform/models/current_user.dart';
import 'package:events_streaming_platform/models/event.dart';
import 'package:events_streaming_platform/models/token.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../classes/helper.dart';
import '../models/user.dart';
import '../screens/home_screen.dart';

abstract class Request {
  static String authority = '192.168.1.13:8000';
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
        var userTokenExpiryDateJson = j['expiry'];
        DateTime userTokenExpiryDate =
            Helper.format.parse(userTokenExpiryDateJson);
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
        if (!context.mounted) return;
        showMessage(context, 'logged in as ${user.username}');
        Navigator.of(context).pushNamed(HomeScreen.routeName);
      } else {
        showMessage(context, 'wrong credentials');
      }
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

  static Future<void> editAccount(
    BuildContext context,
    String firstName,
    String lastName,
    String userName,
    String email,
    String password,
    String bio,
    String headline,
  ) async {
    User? myUser = await CurrentUser.getUser();
    if (myUser == null) {
      if (!context.mounted) return;
      showMessage(context, 'please login first');
      return;
    }
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/users/${myUser.username}/',
    );
    var body = {};
    if (firstName.isNotEmpty) {
      body['first_name'] = firstName;
    }
    if (lastName.isNotEmpty) {
      body['last_name'] = lastName;
    }
    if (userName.isNotEmpty) {
      body['user_name'] = userName;
    }
    if (email.isNotEmpty) {
      body['email'] = email;
    }
    if (password.isNotEmpty) {
      body['password'] = password;
    }
    if (headline.isNotEmpty) {
      body['headline'] = headline;
    }
    if (bio.isNotEmpty) {
      body['bio'] = bio;
    }
    String? token = await Token.getToken();
    if (token == null) {
      if (!context.mounted) return;
      showLoginFirstMessage(context);
      return;
    }
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    http
        .patch(
      url,
      body: json.encode(body),
      headers: headers,
    )
        .then((response) async {
      if (response.statusCode == 200) {
        var j = json.decode(response.body);
        var userJson = j;
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
        showMessage(context, 'account ${user.username} changed successfully');
        Navigator.of(context).pushNamed(HomeScreen.routeName);
      } else {
        showMessage(context, 'account is not changed');
      }
    });
  }

  static Future<List<Event>> getMyOrganizedPublishedEvents({
    BuildContext? context,
    required int offset,
    required int limit,
  }) async {
    String? token = await Token.getToken();
    if (token == null) {
      if (!context!.mounted) return [];
      showLoginFirstMessage(context);
      return [];
    }
    User? myUser = await CurrentUser.getUser();
    if (myUser == null) {
      showLoginFirstMessage(context!);
      return [];
    }
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/users/${myUser.username}/organized-events/',
    );

    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    Future<List<Event>> events = http
        .get(
      url,
      headers: headers,
    )
        .then((response) async {
      if (response.statusCode == 200) {
        var results = json.decode(response.body) as List;
        Future<List<Event>> curEvents =
            Future.wait(results.map((element) async {
          Event curEvent = Event.fromJson(element);
          curEvent.picture = 'http://$authority${curEvent.picture}';
          curEvent.talks = await getTalks(context!, curEvent.id, token);
          return curEvent;
        }).toList());
        curEvents.then((value) {
          value.removeWhere((element) {
            return !element.isPublished;
          });
          return value;
        });
        return curEvents;
      } else {
        showProblemMessage(context!, response.body);
        return [];
      }
    });

    return events;
  }

  static Future<List<Talk>> getTalks(
    BuildContext context,
    int eventId,
    String token,
  ) {
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/events/$eventId/talks/',
      {'include_all': 'true'},
    );

    Future<http.Response> res = http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    Future<List<Talk>> talks = res.then((response) {
      if (response.statusCode == 200) {
        var results = json.decode(response.body) as List;
        List<Talk> curTalks = results.map((element) {
          Talk talk = Talk.fromJson(element);
          return talk;
        }).toList();
        return curTalks;
      } else {
        return [];
      }
    });
    return talks;
  }

  static Future<List<Event>> getMyOrganizedUnPublishedEvents({
    BuildContext? context,
    required int offset,
    required int limit,
  }) async {
    String? token = await Token.getToken();
    if (token == null) {
      showLoginFirstMessage(context!);
      return [];
    }
    User? myUser = await CurrentUser.getUser();
    if (myUser == null) {
      showLoginFirstMessage(context!);
      return [];
    }
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/users/${myUser.username}/organized-events/',
    );

    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    Future<List<Event>> events = http
        .get(
      url,
      headers: headers,
    )
        .then((response) async {
      if (response.statusCode == 200) {
        var results = json.decode(response.body) as List;
        List<Future<Event>> curFutureEvents = results.map((element) async {
          Event curEvent = Event.fromJson(element);
          curEvent.picture = 'http://$authority${curEvent.picture}';
          List<Talk> talks = await getTalks(context!, curEvent.id, token);
          curEvent.talks = talks;
          return curEvent;
        }).toList();
        Future<List<Event>> events = Future.wait(curFutureEvents);
        events.then((value) {
          value.removeWhere((element) {
            return element.isPublished;
          });
        });
        return events;
      } else {
        showProblemMessage(context!, response.body);
        return [];
      }
    });
    return events;
  }

  static Future<List<Event>> getMyUpcomingEvents({
    BuildContext? context,
    required int offset,
    required int limit,
  }) {
    return Future.delayed(Duration(seconds: 5)).then((value) {
      var event = Event(
        id: 1,
        title: 'title',
        organizerName: 'organizerName',
        description: 'description',
        picture: "https://loremflickr.com/320/240/dog",
        date: DateTime.now(),
        isPublished: false,
      );
      return [event, event];
    });
  }

  static Future<List<Event>> getPublishedEvents({
    BuildContext? context,
    required int offset,
    required int limit,
  }) async {
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/events',
      {'limit': limit.toString(), 'offset': offset.toString()},
    );

    Future<http.Response> res = http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    Future<List<Event>> events = res.then((response) {
      var j = json.decode(response.body);
      var results = j['results'] as List;
      int count = j['count'];
      // i've consedired that count is the remaining without
      //the ones that I have in my response
      bool hasMoreEvents = (count > 0);
      List<Event> curEvents = results.map((element) {
        Event curEvent = Event.fromJson(element);
        return curEvent;
      }).toList();
      return curEvents;
    });
    return events;
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
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/events/$eventId/talks',
    );
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

  static postEvent(
    BuildContext context,
    String title,
    String description,
    XFile file,
  ) async {
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
    request.files.add(pic);
    String? token = await Token.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('you\'re not logged in yet'),
      ));
      return;
    }
    var headers = {
      'Accept': '*/*',
      'Authorization': 'Bearer $token',
    };
    request.headers.addAll(headers);
    var response = await request.send();

    //Get the response from the server
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    if (response.statusCode == 201) {
      var j = json.decode(responseString);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('event added to archived'),
      ));
      return j['id'];
    } else {
      showProblemMessage(context, responseString);
      return null;
    }
  }

  static void postTalk(
    BuildContext context,
    int eventId,
    Talk talk,
  ) async {}
  static Future<void> editEvent(
    BuildContext context,
    int eventId,
    String? title,
    String? description,
    DateTime? date,
    List<Talk>? talks,
    XFile? picture,
    bool? isPublished,
  ) async {
    User? myUser = await CurrentUser.getUser();
    if (myUser == null) {
      if (!context.mounted) return;
      showLoginFirstMessage(context);
      return;
    }
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/events/$eventId/',
    );

    String? token = await Token.getToken();
    if (token == null) {
      if (!context.mounted) return;
      showLoginFirstMessage(context);
      return;
    }
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    var body = {};
    if (title != null) {
      body['title'] = title;
    }
    if (description != null) {
      body['description'] = description;
    }
    /*if (date != null) {
      body['date'] = date;
    }*/
    /*if (talks != null) {
      body['talks'] = json.encode(talks);
    }*/
    if (picture != null) {
      body['picture'] = picture;
    }
    if (isPublished != null) {
      body['is_published'] = isPublished;
    }
    http
        .patch(
      url,
      body: json.encode(body),
      headers: headers,
    )
        .then((response) async {
      if (response.statusCode == 200) {
        var j = json.decode(response.body);
        Event e = Event.fromJson(j);
        showMessage(context, 'event is changed');
      } else {
        showMessage(context, 'event is not changed');
      }
    });
  }

  static void logout() async {
    Token.deleteToken();
    CurrentUser.deleteUser();
    Uri url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/auth/logout/',
    );
    String? token = await Token.getToken();
    await http.post(url, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });
  }

  static void showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  static void showLoginFirstMessage(BuildContext context) {
    showMessage(context, 'you have to login first');
  }

  static void showProblemMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
