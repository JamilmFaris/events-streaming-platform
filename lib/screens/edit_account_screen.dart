import 'dart:io';

import 'package:events_streaming_platform/design/tw_colors.dart';
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
    double imageWidth = 100;
    double imageHeight = 100;
    TextEditingController firstNameController = TextEditingController(),
        lastNameController = TextEditingController(),
        passwordController = TextEditingController(),
        verifyPasswordController = TextEditingController(),
        bioController = TextEditingController(),
        headlineController = TextEditingController();
    Image addImage = Image.asset('assets/images/add_image.png');
    return Scaffold(
      backgroundColor: TwColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text('edit account'),
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: AuthArguments.appbarPadding),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: pick,
                child: image == null
                    ? getSizedImage(addImage, imageHeight, imageWidth)
                    : getSizedImage(
                        Image.file(File(image!.path)),
                        imageHeight,
                        imageWidth,
                      ),
              ),
              AuthArguments.authTextField(
                controller: firstNameController,
                textType: 'first name',
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              AuthArguments.authTextField(
                controller: lastNameController,
                textType: 'last name',
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
                textInputAction: TextInputAction.next,
              ),
              AuthArguments.authTextField(
                controller: bioController,
                textType: 'bio',
                textInputAction: TextInputAction.next,
              ),
              AuthArguments.authTextField(
                controller: headlineController,
                textType: 'headline',
              ),
              AuthArguments.authFilledButton(
                onPressed: () {
                  Request.editAccount(
                    context,
                    firstNameController.text,
                    lastNameController.text,
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
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Widget getSizedImage(Image image, double height, double width) {
    return Center(
      child: Container(
        height: height,
        width: width,
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
