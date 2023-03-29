import 'package:flutter/material.dart';

import '../request/request.dart';
import '../classes/auth_arguments.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController userNameController = TextEditingController(),
        passwordController = TextEditingController();
    const double bottomPadding = AuthArguments.bottomPadding;
    return Scaffold(
      appBar: AppBar(title: const Text('login')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.only(bottom: bottomPadding),
          child: AuthArguments.authTextField(
            autofocus: true,
            controller: userNameController,
            textType: 'login',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: bottomPadding),
          child: AuthArguments.authTextField(
            controller: userNameController,
            textType: 'login',
            obscureText: true,
          ),
        ),
        AuthArguments.authFilledButton(
          onPressed: () {
            if (userNameController.text != "" &&
                passwordController.text != "") {
              Request.login(
                userNameController.text,
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
