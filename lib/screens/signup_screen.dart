import 'package:events_streaming_platform/classes/tw_colors.dart';
import 'package:flutter/material.dart';

import '../classes/auth_arguments.dart';
import '../request/request.dart';

class SignupScreen extends StatelessWidget {
  static const routeName = '/signup';
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController firstNameController = TextEditingController(),
        lastNameController = TextEditingController(),
        userNameController = TextEditingController(),
        emailController = TextEditingController(),
        passwordController = TextEditingController(),
        verifyPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: TwColors.backgroundColor(context),
      appBar: AppBar(title: const Text('signup')),
      body: Container(
        alignment: Alignment.center,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: AuthArguments.appbarPadding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                AuthArguments.authTextField(
                  autofocus: true,
                  controller: firstNameController,
                  textType: 'first name',
                  textInputAction: TextInputAction.next,
                ),
                AuthArguments.authTextField(
                  controller: lastNameController,
                  textType: 'last name',
                  textInputAction: TextInputAction.next,
                ),
                AuthArguments.authTextField(
                  controller: userNameController,
                  textType: 'username',
                  textInputAction: TextInputAction.next,
                ),
                AuthArguments.authTextField(
                  controller: emailController,
                  textType: 'email',
                  textInputType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                AuthArguments.authTextField(
                  controller: passwordController,
                  textType: 'password',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                AuthArguments.authTextField(
                  controller: verifyPasswordController,
                  textType: 'password again',
                  obscureText: true,
                  label: 'Verify password',
                ),
                AuthArguments.authFilledButton(
                  onPressed: () {
                    if (passwordController.text ==
                            verifyPasswordController.text &&
                        firstNameController.text.isNotEmpty &&
                        lastNameController.text.isNotEmpty &&
                        userNameController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty) {
                      Request.signup(
                        firstNameController.text,
                        lastNameController.text,
                        userNameController.text,
                        emailController.text,
                        passwordController.text,
                      );
                    }
                  },
                  child: const Text('signup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
