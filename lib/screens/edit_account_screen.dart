import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../request/request.dart';
import '../classes/auth_arguments.dart';

class EditAccountScreen extends StatefulWidget {
  static const String routeName = '/editAccount';
  EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  XFile? image;

  @override
  Widget build(BuildContext context) {
    TextEditingController firstNameController = TextEditingController(),
        lastNameController = TextEditingController(),
        userNameController = TextEditingController(),
        emailController = TextEditingController(),
        passwordController = TextEditingController(),
        verifyPasswordController = TextEditingController(),
        bioController = TextEditingController(),
        headlineController = TextEditingController();
    Image addImage = Image.asset('assets/images/add_image.png');
    return Scaffold(
      appBar: AppBar(
        title: const Text('edit account'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            image == null
                ? GestureDetector(
                    onTap: pick,
                    child: addImage,
                  )
                : Image.file(
                    File(image!.path),
                    height: addImage.height,
                    width: addImage.width,
                  ),
            AuthArguments.authTextField(
              controller: firstNameController,
              textType: 'first name',
              autofocus: true,
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
            ),
            AuthArguments.authTextField(
              controller: bioController,
              textType: 'bio',
            ),
            AuthArguments.authTextField(
              controller: headlineController,
              textType: 'headline',
            ),
            AuthArguments.authFilledButton(
              onPressed: () {
                Request.editAccount(
                  firstNameController.text,
                  lastNameController.text,
                  userNameController.text,
                  emailController.text,
                  passwordController.text,
                  bioController.text,
                  headlineController.text,
                );
              },
              child: const Text('edit my account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pick() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: AuthArguments.accountImageMaxSize.height,
        maxWidth: AuthArguments.accountImageMaxSize.width,
      );
      if (image == null) return;
      setState(() {
        this.image = image;
        print(image.path);
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Widget getSizedImage(Image image) {
    return Center(
      child: Container(
        height: 128,
        width: 128,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitWidth,
            alignment: FractionalOffset.topCenter,
            image: image.image,
          ),
        ),
      ),
    );
  }
}
