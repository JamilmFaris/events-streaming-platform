import 'package:flutter/material.dart';

import '../classes/auth_arguments.dart';
import '../request/request.dart';

class SignUpScreen extends StatelessWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController firstNameController = TextEditingController(),
        lastNameController = TextEditingController(),
        userNameController = TextEditingController(),
        emailController = TextEditingController(),
        passwordController = TextEditingController(),
        verifyPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('signup')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthArguments.authTextField(
              controller: firstNameController,
              textType: 'first name',
            ),
            AuthArguments.authTextField(
              controller: lastNameController,
              textType: 'last name',
            ),
            AuthArguments.authTextField(
              controller: userNameController,
              textType: 'username',
            ),
            AuthArguments.authTextField(
              controller: emailController,
              textType: 'email',
              textInputType: TextInputType.emailAddress,
            ),
            AuthArguments.authTextField(
              controller: passwordController,
              textType: 'password',
              obscureText: true,
            ),
            AuthArguments.authTextField(
              controller: verifyPasswordController,
              textType: 'password again',
              obscureText: true,
              label: 'Verify password',
            ),
            AuthArguments.authFilledButton(
              onPressed: () {
                if (passwordController.text == verifyPasswordController.text &&
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
    );
  }
}
