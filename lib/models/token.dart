import 'package:events_streaming_platform/models/current_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../classes/helper.dart';

class Token {
  static Future<void> storeToken(String token, DateTime expiry) async {
    AndroidOptions getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());

    // Generate a key pair
    //final keyPair = await storage.generateKeyPair();

    await storage.write(key: 'token', value: token);
    await storage.write(key: 'expiry', value: expiry.toString());
  }

  static Future<String?> getToken() async {
    AndroidOptions getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    final token = await storage.read(key: 'token');
    final expiry = await storage.read(key: 'expiry');
    if (expiry != null) {
      DateTime expiryDate = DateTime.parse(expiry);
      if (expiryDate.isBefore(DateTime.now())) {
        deleteToken();
        return null;
      }
      return token;
    }
    return null;
  }

  static Future<void> deleteToken() async {
    AndroidOptions getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    await storage.delete(key: 'token');
    await CurrentUser.deleteUser();
  }
}
