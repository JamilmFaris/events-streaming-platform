import 'package:events_streaming_platform/design/tw_colors.dart';
import 'package:flutter/material.dart';

import '../request/request.dart';
import '../classes/auth_arguments.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController(),
        passwordController = TextEditingController();
    const double bottomPadding = AuthArguments.bottomPadding;
    return Scaffold(
      backgroundColor: TwColors.backgroundColor(context),
      appBar: AppBar(title: const Text('login')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.only(bottom: bottomPadding),
          child: AuthArguments.authTextField(
            autofocus: true,
            controller: usernameController,
            textType: 'username',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: bottomPadding),
          child: AuthArguments.authTextField(
            controller: passwordController,
            textType: 'password',
            obscureText: true,
          ),
        ),
        AuthArguments.authFilledButton(
          onPressed: () {
            if (usernameController.text != "" &&
                passwordController.text != "") {
              Request.login(
                context,
                usernameController.text,
                passwordController.text,
              );
            }
          },
          child: const Text('login'),
        )
      ]),
    );
  }
}
