import 'package:events_streaming_platform/models/current_user.dart';
import 'package:events_streaming_platform/models/event.dart';
import 'package:events_streaming_platform/models/token.dart';
import 'package:events_streaming_platform/screens/organized_events_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../classes/helper.dart';
import '../models/user.dart';
import '../screens/home_screen.dart';
import '../screens/invitations_screen.dart';

abstract class Request {
  static String authority = '192.168.1.9:8080';
  static String databaseVersion = '/v1';
  static String urlPrefix = '/api';

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
            Helper.format2.parse(userTokenExpiryDateJson);
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
      } else if (response.statusCode >= 400) {
        showProblemMessage(context, 'wrong credentials');
      } else {
        showProblemMessage(context, 'an error occured');
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
      if (!context!.mounted) return [];
      showLoginFirstMessage(context);
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
        var res = json.decode(response.body);
        if (res['detail'] == 'Invalid token.') {
          showLoginFirstMessage(context!);
        } else {
          showProblemMessage(context!, 'problem occured');
        }
        return [];
      }
    });

    return events;
  }

  static Future<List<Talk>> getTalks(
    BuildContext context,
    int eventId,
    String? token,
  ) async {
    token ??= await Token.getToken();
    if (token == null) {
      if (!context.mounted) return [];
      showLoginFirstMessage(context);
    }
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
      '$urlPrefix$databaseVersion/users/${myUser.username}/booked-events/',
      {'limit': limit.toString(), 'offset': offset.toString()},
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
        final j = json.decode(response.body);
        var results = j['results'] as List;
        Future<List<Event>> curEvents =
            Future.wait(results.map((element) async {
          Event curEvent = Event.fromJson(element);
          curEvent.talks = await getTalks(context!, curEvent.id, token);
          return curEvent;
        }).toList());
        return curEvents;
      } else {
        showProblemMessage(context!, response.body);
        return [];
      }
    });

    return events;
  }

  static Future<List<Event>> getPublishedEvents({
    BuildContext? context,
    required int offset,
    required int limit,
  }) async {
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/events',
      {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'only_upcoming': true.toString(),
      },
    );
    print('get published events');
    Future<http.Response> res = http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    String? token = await Token.getToken();
    if (token == null) {
      if (!context!.mounted) return [];
      showLoginFirstMessage(context);
      return [];
    }
    Future<List<Event>> events = res.then((response) {
      var j = json.decode(response.body);
      var results = j['results'] as List;
      List<Future<Event>> curEvents = results.map((element) async {
        Event curEvent = Event.fromJson(element);
        curEvent.talks = await getTalks(context!, curEvent.id, token);
        return curEvent;
      }).toList();
      return Future.wait(curEvents);
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
      if (!context.mounted) return null;
      showLoginFirstMessage(context);
      return null;
    }
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/events/$eventId/talks/',
    );
    http.post(
      url,
      body: json.encode({
        'speaker': speakerUsername,
        'title': talkTitle,
        'start': Helper.getFormattedDateString(start),
        'end': Helper.getFormattedDateString(end),
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

  static Future<bool> changeTalkStatus({
    required BuildContext context,
    required int talkId,
    required TalkStatus wantedStatus,
  }) async {
    String? token = await Token.getToken();
    if (token == null) {
      if (!context.mounted) return false;
      showLoginFirstMessage(context);
      return false;
    }
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/talks/$talkId/',
    );

    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    var body = {};
    if (wantedStatus == TalkStatus.approved) {
      body = {'status': 'approved'};
    } else if (wantedStatus == TalkStatus.rejected) {
      body = {'status': 'rejected'};
    }
    return http
        .patch(
      url,
      body: json.encode(body),
      headers: headers,
    )
        .then((response) {
      if (response.statusCode == 200) {
        if (!context.mounted) return false;
        var message = (wantedStatus == TalkStatus.approved)
            ? 'talk approved'
            : 'talk rejected';
        showMessage(
          context,
          message,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InvitationsScreen(),
          ),
        );
        return true;
      } else {
        if (!context.mounted) return false;
        showProblemMessage(context, 'an error occured');
        return false;
      }
    });
  }

  static Future<String?> getTalkKey(BuildContext context) async {
    User? myUser = await CurrentUser.getUser();
    if (myUser == null) {
      if (!context.mounted) return null;
      showLoginFirstMessage(context);
      return null;
    }
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/users/{username}/play-stream-key/',
    );

    String? token = await Token.getToken();
    if (token == null) {
      if (!context.mounted) return null;
      showLoginFirstMessage(context);
      return '';
    }
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    return http
        .get(
      url,
      headers: headers,
    )
        .then((response) {
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        return responseBody['play_stream_key'];
      } else {
        showProblemMessage(context, response.body);
        print('error occured ${response.body}');
        return null;
      }
    });
  }

  static Future<void> deleteTalk(BuildContext context, int talkId) async {
    String? token = await Token.getToken();
    if (token == null) {
      if (!context.mounted) return;
      showLoginFirstMessage(context);
      return;
    }
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/talks/$talkId/',
    );
    return await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    ).then((value) {
      if (value.statusCode == 204) {
        showMessage(context, 'talk deleted succesfully');
        Navigator.popUntil(
          context,
          (route) => !Navigator.canPop(context),
          //pop until you cannot pop (HomeScreen)
        );
        Navigator.pushNamed(
          context,
          OrganizedEventsScreen.routeName,
        );
        return;
      } else {
        showProblemMessage(context, 'talk is not deleted');
        return;
      }
    });
  }

  static postEvent(
    BuildContext context,
    String title,
    String description,
    XFile file,
    DateTime start,
  ) async {
    var url = Uri.http(authority, '$urlPrefix$databaseVersion/events/');
    var request = http.MultipartRequest("POST", url);

    var fields = {
      'title': title,
      'description': description,
      'started_at': Helper.getFormattedDateString(start),
    };
    request.fields.addAll(fields);

    var pic = await http.MultipartFile.fromPath("picture", file.path);
    request.files.add(pic);
    String? token = await Token.getToken();
    if (token == null) {
      if (!context.mounted) return;
      showLoginFirstMessage(context);
      return;
    }
    var headers = {
      'Accept': '*/*',
      'Authorization': 'Bearer $token',
    };
    request.headers.addAll(headers);
    var response = await request.send();

    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    if (response.statusCode == 201) {
      var j = json.decode(responseString);
      if (!context.mounted) return;
      showMessage(context, 'event added to archived');
      return j['id'];
    } else {
      if (!context.mounted) return;
      showProblemMessage(context, responseString);
      return null;
    }
  }

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

  static Future<bool> bookEvent({
    required BuildContext context,
    required int eventId,
  }) async {
    String? token = await Token.getToken();
    if (token == null) {
      if (!context.mounted) return false;
      showLoginFirstMessage(context);
      return false;
    }
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/events/$eventId/bookings/',
    );
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    ).then((response) {
      print(response.statusCode);
      if (response.statusCode == 204) {
        if (!context.mounted) return false;
        showMessage(context, 'event booked');
        return true;
      } else if (response.statusCode == 409) {
        showProblemMessage(context, 'you\'ve already booked this event');
        return false;
      } else {
        showProblemMessage(context, 'event isn\'t booked');
        return false;
      }
    });
  }

  static Future<bool> cancelBookingEvent({
    required BuildContext context,
    required int eventId,
  }) async {
    String? token = await Token.getToken();
    if (token == null) {
      if (!context.mounted) return false;
      showLoginFirstMessage(context);
      return false;
    }
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/events/$eventId/bookings/',
    );
    return await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    ).then((value) {
      if (value.statusCode == 204) {
        if (!context.mounted) return true;
        showMessage(context, 'event booking canceled');
        return true;
      } else {
        showProblemMessage(context, 'event isn\'t canceled');
        return false;
      }
    });
  }

  static Future<bool> isEventBooked(
    BuildContext context,
    int eventId,
  ) async {
    int offset = 0, limit = 20;
    List<Event> events = [];
    List<Event> curEvents = await getMyUpcomingEvents(
      context: context,
      offset: offset,
      limit: limit,
    );
    events.addAll(curEvents);
    while (curEvents.length >= limit) {
      offset += limit;
      curEvents = await getMyUpcomingEvents(
        offset: offset,
        limit: limit,
      );
      events.addAll(curEvents);
    }
    for (var event in events) {
      if (event.id == eventId) {
        return true;
      }
    }
    return false;
  }

  static Future<List<Talk>> getInvitations(BuildContext context) async {
    String? token = await Token.getToken();
    if (token == null) {
      if (!context.mounted) return [];
      showLoginFirstMessage(context);
      return [];
    }
    User? myUser = await CurrentUser.getUser();
    if (myUser == null) {
      showLoginFirstMessage(context);
      return [];
    }
    var url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/users/${myUser.username}/talks/',
    );

    Future<http.Response> res = http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    Future<List<Talk>> invitations = res.then((response) {
      if (response.statusCode == 200) {
        var results = json.decode(response.body) as List;
        List<Talk> curInvitations = results.map((element) {
          Talk invitation = Talk.invitationFromJson(
            element,
            myUser.username,
          );
          return invitation;
        }).toList();
        return curInvitations;
      } else {
        return [];
      }
    });
    return invitations;
  }

  static void logout(BuildContext context) async {
    Token.deleteToken();
    CurrentUser.deleteUser();
    Uri url = Uri.http(
      authority,
      '$urlPrefix$databaseVersion/auth/logout/',
    );
    String? token = await Token.getToken();
    return await http.post(url, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    }).then((value) => {
          if (value.statusCode == 204)
            if (context.mounted) showMessage(context, 'logged out')
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
