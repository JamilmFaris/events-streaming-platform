import 'dart:io';

import 'package:events_streaming_platform/models/event.dart';
import 'package:events_streaming_platform/screens/home_screen.dart';
import 'package:events_streaming_platform/screens/organized_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../classes/event_arguments.dart';
import '../classes/helper.dart';
import '../design/tw_colors.dart';
import '../request/request.dart';

class CreateEventScreen extends StatefulWidget {
  static const routeName = '/createEvent';
  CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  DateTime? _selectedDate;
  void _presentStartDatePicker() async {
    if (!context.mounted) {
      return;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(seconds: 1)),
      firstDate: DateTime.now().add(const Duration(seconds: 1)),
      lastDate: DateTime.now().add(
        const Duration(days: 1000),
      ),
    );
    if (picked != null) {
      if (!context.mounted) return;
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePicked != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }

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
          TextButton(
            onPressed: _presentStartDatePicker,
            child: (_selectedDate == null)
                ? Row(
                    children: const [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                      ),
                      Text(
                        'pick a start date for the event',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  )
                : Text(
                    'picked date is\n${Helper.getFormattedDateWithTime(_selectedDate!)}'),
          ),
          EventArguments.eventFilledButton(
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
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('pick a start date for the event first'),
      ));
      return;
    }
    Request.postEvent(
      context,
      nameController.text,
      descriptionController.text,
      image!,
      _selectedDate!,
    );
    Navigator.pushNamed(context, HomeScreen.routeName);
  }
}
