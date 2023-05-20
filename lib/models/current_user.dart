import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'user.dart';

class CurrentUser {
  static Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString('user');
    User? user;
    if (userString != null) {
      var userJson = json.decode(userString);
      user = User(
        firstName: userJson['firstName'],
        lastName: userJson['lastName'],
        username: userJson['username'],
        email: userJson['email'],
        avatar: userJson['avatar'],
        bio: userJson['bio'],
        headline: userJson['headline'],
      );
    }
    return user;
  }

  static Future<void> storeUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userString = json.encode({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'username': user.username,
      'email': user.email,
      'avatar': user.avatar,
      'bio': user.bio,
      'headline': user.headline,
    });
    prefs.setString('user', userString);
  }

  static Future<void> deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }
}
