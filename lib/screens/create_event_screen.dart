import 'dart:io';

import 'package:events_streaming_platform/models/event.dart';
import 'package:events_streaming_platform/screens/home_screen.dart';
import 'package:events_streaming_platform/screens/organized_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../classes/event_arguments.dart';
import '../design/tw_colors.dart';
import '../request/request.dart';

class CreateEventScreen extends StatefulWidget {
  static const routeName = '/createEvent';
  CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<Talk> talks = [];
  XFile? image;

  @override
  Widget build(BuildContext context) {
    double imageWidth = MediaQuery.of(context).size.width * 0.25;
    double imageHeight = 100;
    Image addImage = Image.asset('assets/images/add_image.png');
    return Scaffold(
      backgroundColor: TwColors.backgroundColor(context),
      appBar: AppBar(title: const Text('Create New Event')),
      body: ListView(
        children: [
          GestureDetector(
            // todo make a separate choose_image_widget.dart file
            onTap: pick,
            child: image == null
                ? getSizedImage(addImage, imageHeight, imageWidth)
                : getSizedImage(
                    Image.file(File(image!.path)),
                    imageHeight,
                    imageWidth,
                  ),
          ),
          EventArguments.createTextField(
            controller: nameController,
            textType: 'name',
          ),
          EventArguments.createTextField(
            controller: descriptionController,
            textType: 'description',
          ),
          EventArguments.EventFilledButton(
            onPressed: () => addEvent(context),
            child: const Text('save to archived'),
          ),
        ],
      ),
    );
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

  Future<void> pick() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: EventArguments.accountImageMaxSize.height,
        maxWidth: EventArguments.accountImageMaxSize.width,
      );
      if (image == null) return;
      setState(() {
        this.image = image;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  void addTalk(Talk talk) {
    setState(() {
      talks.add(talk);
      print(talks);
    });
  }

  void addEvent(BuildContext context) {
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('add image for your event'),
      ));
      return;
    }
    Request.postEvent(
      context,
      nameController.text,
      descriptionController.text,
      image!,
    );
    Navigator.pushNamed(context, OrganizedEventsScreen.routeName);
  }
}
